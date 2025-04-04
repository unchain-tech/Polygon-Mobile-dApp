import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

class TodoListModel extends ChangeNotifier {
  List<Task> todos = [];
  bool isLoading = false;
  int? taskCount;

  Web3Client? _client;
  String? _abiCode;

  String? _deepLinkUrl;
  String? _account;
  Web3App? _wcClient;
  SessionData? _sessionData;
  EthereumAddress? _contractAddress;
  DeployedContract? _contract;

  ContractFunction? _taskCount;
  ContractFunction? _todos;
  ContractFunction? _createTask;
  ContractFunction? _updateTask;
  ContractFunction? _deleteTask;
  ContractFunction? _toggleComplete;

  TodoListModel() {
    init();
  }

  Future<void> init() async {
    var httpClient = Client();

    _client = Web3Client(dotenv.env["POLYGON_MUMBAI_INFURA_KEY"]!, httpClient);

    await getAbi();
    await getDeployedContract();
  }

  Future<void> setWalletDetails(
      String deepLinkUrl, Web3App wcClient, SessionData sessionData) async {
    _deepLinkUrl = deepLinkUrl;
    _wcClient = wcClient;
    _sessionData = sessionData;
    // セッションを認証したアカウントを取得します。
    _account = NamespaceUtils.getAccount(
        sessionData.namespaces.values.first.accounts.first);

    notifyListeners();
  }

  //スマートコントラクトの`ABI`を取得し、デプロイされたコントラクトのアドレスを取り出す。
  Future<void> getAbi() async {
    String abiStringFile =
        await rootBundle.loadString("smartcontract/TodoContract.json");
    var jsonAbi = jsonDecode(abiStringFile);
    _abiCode = jsonEncode(jsonAbi["abi"]);
    _contractAddress = EthereumAddress.fromHex(dotenv.env["CONTRACT_ADDRESS"]!);
  }

  //`_abiCode`と`_contractAddress`を使用して、スマートコントラクトのインスタンスを作成する。
  Future<void> getDeployedContract() async {
    isLoading = true;
    _contract = DeployedContract(
        ContractAbi.fromJson(_abiCode!, "TodoList"), _contractAddress!);
    _taskCount = _contract!.function("taskCount");
    _updateTask = _contract!.function("updateTask");
    _createTask = _contract!.function("createTask");
    _deleteTask = _contract!.function("deleteTask");
    _toggleComplete = _contract!.function("toggleComplete");
    _todos = _contract!.function("todos");

    await getTodos();

    isLoading = false;
  }

  //すべてのto-do項目を取得してリストに追加する。
  Future<void> getTodos() async {
    List totalTaskList = await _client!
        .call(contract: _contract!, function: _taskCount!, params: []);

    BigInt totalTask = totalTaskList[0];
    int taskCount = totalTask.toInt();
    todos.clear();
    for (var i = 0; i < taskCount; i++) {
      var temp = await _client!.call(
          contract: _contract!, function: _todos!, params: [BigInt.from(i)]);
      if (temp[1] != "")
        todos.add(
          Task(
            id: (temp[0] as BigInt).toInt(),
            taskName: temp[1],
            isCompleted: temp[2],
          ),
        );
    }
    todos = todos.reversed.toList();

    notifyListeners();
  }

  EthereumTransaction generateTransaction(
      ContractFunction function, List<dynamic> parameters) {
    // web3dartを使用して、トランザクションを作成します。
    final Transaction transaction = Transaction.callContract(
        contract: _contract!, function: function, parameters: parameters);

    // walletconnect_flutter_v2を使用して、Ethereumトランザクションを作成します。
    final EthereumTransaction ethereumTransaction = EthereumTransaction(
      from: _account!,
      to: dotenv.env["CONTRACT_ADDRESS"]!,
      value: '0x${transaction.value?.getInWei.toRadixString(16) ?? '0'}',
      data: transaction.data != null ? bytesToHex(transaction.data!) : null,
    );

    return ethereumTransaction;
  }

  Future<String> sendTransaction(EthereumTransaction transaction) async {
    // Metamaskアプリケーションを起動します。
    await launchUrlString(_deepLinkUrl!, mode: LaunchMode.externalApplication);

    // 署名をリクエストします。
    final String signResponse = await _wcClient?.request(
      topic: _sessionData?.topic ?? "",
      chainId: 'eip155:80001',
      request: SessionRequestParams(
        method: 'eth_sendTransaction',
        params: [transaction.toJson()],
      ),
    );

    return signResponse;
  }

  //1.to-doを作成する機能
  Future<void> addTask(String taskNameData) async {
    isLoading = true;
    notifyListeners();
    try {
      final EthereumTransaction ethereumTransaction =
          await generateTransaction(_createTask!, [taskNameData]);

      final String signResponse = await sendTransaction(ethereumTransaction);
      debugPrint("=== signResponse: $signResponse");

      await getTodos();
    } catch (error) {
      debugPrint('=== toggleComplete: $error');
    } finally {
      isLoading = false;
    }
  }

  //2.to-doを更新する機能
  Future<void> updateTask(int id, String taskNameData) async {
    isLoading = true;
    notifyListeners();
    try {
      final EthereumTransaction ethereumTransaction = await generateTransaction(
          _updateTask!, [BigInt.from(id), taskNameData]);

      final String signResponse = await sendTransaction(ethereumTransaction);
      debugPrint("=== signResponse: $signResponse");

      await getTodos();
    } catch (error) {
      debugPrint('=== toggleComplete: $error');
    } finally {
      isLoading = false;
    }
  }

  //3.to-doの完了・未完了を切り替える機能
  Future<void> toggleComplete(int id) async {
    isLoading = true;
    notifyListeners();
    try {
      final EthereumTransaction ethereumTransaction =
          await generateTransaction(_toggleComplete!, [BigInt.from(id)]);

      final String signResponse = await sendTransaction(ethereumTransaction);
      debugPrint("=== signResponse: $signResponse");

      await getTodos();
    } catch (error) {
      debugPrint('=== toggleComplete: $error');
    } finally {
      isLoading = false;
    }
  }

  //4.to-doを削除する機能
  Future<void> deleteTask(int id) async {
    isLoading = true;
    notifyListeners();
    try {
      final EthereumTransaction ethereumTransaction =
          await generateTransaction(_deleteTask!, [BigInt.from(id)]);

      final String signResponse = await sendTransaction(ethereumTransaction);
      debugPrint('=== signResponse: $signResponse');

      await getTodos();
    } catch (error) {
      debugPrint('=== deleteTask: $error');
    } finally {
      isLoading = false;
    }
  }
}

//to-doのリストを格納するモデルクラス
class Task {
  final int? id;
  final String? taskName;
  final bool? isCompleted;
  Task({this.id, this.taskName, this.isCompleted});
}

// Ethereumトランザクションを作成するためのモデルクラス
class EthereumTransaction {
  const EthereumTransaction({
    required this.from,
    required this.to,
    required this.value,
    this.data,
  });

  final String from;
  final String to;
  final String value;
  final String? data;

  Map<String, dynamic> toJson() => {
        'from': from,
        'to': to,
        'value': value,
        'data': data,
      };
}
