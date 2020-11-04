import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cse_bpm_project/model/CountRIToday.dart';
import 'package:cse_bpm_project/model/InputField.dart';
import 'package:cse_bpm_project/model/InputFieldInstance.dart';
import 'package:cse_bpm_project/model/NumOfRequestInstance.dart';
import 'package:cse_bpm_project/model/RequestInstance.dart';
import 'package:cse_bpm_project/model/Role.dart';
import 'package:cse_bpm_project/model/Step.dart';
import 'package:http/http.dart' as http;

import 'package:cse_bpm_project/model/StepInstance.dart';
import 'package:intl/intl.dart';

class WebService {
//  /// Singleton
//
//  static final WebService _singleton = WebService._internal();
//
//  factory WebService() {
//    return _singleton;
//  }
//
//  WebService._internal();

  /// Variable

  int nextStepSize = 0;
  int count = 0;
  final DateFormat formatterDateTime = DateFormat('yyyy-MM-ddThh:mm:ss-07:00');

  /// Web API

  /// Request

  Future<void> patchRequestNumOfSteps(
      int requestID, int numOfSteps, Function updateData) async {
    var resBody = {};
    resBody["NumOfSteps"] = "$numOfSteps";
    String str = json.encode(resBody);

    final http.Response response = await http.patch(
      'http://nkkha.somee.com/odata/tbRequest($requestID)',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: str,
    );

    if (response.statusCode == 200) {
      updateData(true);
    } else {
      updateData(false);
      throw Exception('Failed to update request instance');
    }
  }

  ///

  // StepInstance
  Future<List<StepInstance>> getStepInstances(
      int tabIndex, int requestInstanceID) async {
    final response = await http.get(
        'http://nkkha.somee.com/odata/tbStepInstance/GetStepInstanceDetails?\$filter=StepIndex eq $tabIndex and RequestInstanceID eq $requestInstanceID');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['value'];
      List<StepInstance> listStepInstance = new List();
      for (Map i in data) {
        listStepInstance.add(StepInstance.fromJson(i));
      }
      return listStepInstance;
    } else {
      throw Exception('Failed to load');
    }
  }

  Future<void> patchRequestInstanceFailed(
      int requestInstanceID, Function updateData) async {
    var resBody = {};
    // indexType = 1: Reject, indexType = 2: Approve
    resBody["Status"] = "failed";
    String str = json.encode(resBody);

    final http.Response response = await http.patch(
      'http://nkkha.somee.com/odata/tbRequestInstance($requestInstanceID)',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: str,
    );

    if (response.statusCode == 200) {
      updateData();
    } else {
      updateData();
      throw Exception('Failed to update request instance');
    }
  }

  Future<void> patchRequestInstanceStepIndex(
      RequestInstance requestInstance, Function update) async {
    var resBody = {};
    resBody["CurrentStepIndex"] = requestInstance.currentStepIndex + 1;
    String str = json.encode(resBody);

    final http.Response response = await http.patch(
      'http://nkkha.somee.com/odata/tbRequestInstance(${requestInstance.id})',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: str,
    );

    if (response.statusCode == 200) {
      getNextStep(requestInstance, requestInstance.currentStepIndex, update);
    } else {
      update(false);
      throw Exception('Failed to update request instance');
    }
  }

  Future<void> patchRequestInstanceFinished(
      int requestInstanceID, Function update) async {
    var resBody = {};
    // indexType = 1: Reject, indexType = 2: Approve
    resBody["Status"] = "done";
    resBody["FinishedDate"] = formatterDateTime.format(DateTime.now());
    String str = json.encode(resBody);

    final http.Response response = await http.patch(
      'http://nkkha.somee.com/odata/tbRequestInstance($requestInstanceID)',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: str,
    );

    if (response.statusCode == 200) {
      update();
    } else {
      update();
      throw Exception('Failed to update request instance');
    }
  }

  Future<void> getNextStep(RequestInstance requestInstance, int nextStepIndex,
      Function update) async {
    final response = await http.get(
        'http://nkkha.somee.com/odata/tbStep?\$filter=RequestID eq ${requestInstance.requestID} and StepIndex eq $nextStepIndex');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['value'];
      List<Step> listStep = new List();
      for (Map i in data) {
        listStep.add(Step.fromJson(i));
      }
      nextStepSize = listStep.length;
      for (int i = 0; i < nextStepSize; i++) {
        postCreateNextStepInstances(requestInstance.id, listStep[i].id, update);
      }
    } else {
      throw Exception('Failed to load');
    }
  }

  Future<void> getOtherCurrentStepInstances(
      RequestInstance requestInstance,
      int currentStepInstanceID,
      int currentStepIndex,
      bool isLastStep,
      Function update) async {
    final response = await http.get(
        'http://nkkha.somee.com/odata/tbStepInstance/GetStepInstanceDetails?\$filter=RequestInstanceID eq ${requestInstance.id} and StepIndex eq $currentStepIndex and id ne $currentStepInstanceID');

    bool isCompleted = true;

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['value'];
      List<StepInstance> listStepInstance = new List();
      for (Map i in data) {
        listStepInstance.add(StepInstance.fromJson(i));
      }
      for (int i = 0; i < listStepInstance.length; i++) {
        if (listStepInstance[i].status.contains('active') ||
            listStepInstance[i].status.contains('failed')) {
          isCompleted = false;
          update(false);
          break;
        }
      }
      if (isCompleted && !isLastStep) {
        patchRequestInstanceStepIndex(requestInstance, update);
      } else if (isCompleted && isLastStep) {
        update(200);
      }
    } else {
      throw Exception('Failed to load');
    }
  }

  Future<void> postCreateNextStepInstances(
      int requestInstanceID, int stepID, Function update) async {
    final http.Response response = await http.post(
      'http://nkkha.somee.com/odata/tbStepInstance',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "RequestInstanceID": "$requestInstanceID",
        "ApproverID": null,
        "DefaultContent": "",
        "Status": "active",
        "StepID": "$stepID",
        "ResponseMessage": ""
      }),
    );

    if (response.statusCode == 200) {
      count++;
      if (count == nextStepSize) {
        update(true);
      }
    } else {
      throw Exception('Failed to create next step instances.');
    }
  }

  Future<void> postCreateStep(int requestID, String name, String description,
      int approverRoleID, int stepIndex, Function update) async {
    final http.Response response = await http.post(
      'http://nkkha.somee.com/odata/tbStep',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "RequestID": "$requestID",
        "Name": name,
        "Description": description,
        "ApproverRoleID": "$approverRoleID",
        "StepIndex": "$stepIndex"
      }),
    );

    if (response.statusCode == 200) {
      Step step = Step.fromJson(jsonDecode(response.body));
      update(step.id);
    } else {
      throw Exception('Failed to create next step instances.');
    }
  }

  /// Role

  Future<List<Role>> getListRole() async {
    final response = await http.get('http://nkkha.somee.com/odata/tbRole');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['value'];
      List<Role> listRole = new List();
      for (Map i in data) {
        listRole.add(Role.fromJson(i));
      }
      return listRole;
    } else {
      throw Exception('Failed to get list role!');
    }
  }

  /// InputField

  Future<void> postCreateInputField(int stepID, int requestID,
      int inputFieldTypeID, String title, Function update) async {
    final http.Response response = await http.post(
      'http://nkkha.somee.com/odata/tbInputField',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "StepID": stepID == null ? null : "$stepID",
        "RequestID": requestID == null ? null : "$requestID",
        "InputFieldTypeID": "$inputFieldTypeID",
        "Title": title
      }),
    );

    if (response.statusCode == 200) {
      update(true);
    } else {
      throw Exception("Failed to create input field");
    }
  }

  Future<List<InputField>> getListInputField(int requestID, int stepID) async {
    String query = "";
    if (requestID != null) {
      query = "RequestID eq $requestID";
    } else if (stepID != null) {
      query = "StepID eq $stepID";
    }
    final response = await http
        .get('http://nkkha.somee.com/odata/tbInputField?\$filter=$query');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['value'];
      List<InputField> listInputField = new List();
      for (Map i in data) {
        listInputField.add(InputField.fromJson(i));
      }
      return listInputField;
    } else {
      throw Exception('Failed to get list input field!');
    }
  }

  /// InputFieldInstance

  Future<void> postCreateInputTextFieldInstance(
      int stepInstanceID,
      int requestInstanceID,
      int inputFieldID,
      String textAnswer,
      Function update) async {
    final http.Response response = await http.post(
      'http://nkkha.somee.com/odata/tbInputFieldInstance',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "StepInstanceID": stepInstanceID == null ? null : "$stepInstanceID",
        "RequestInstanceID":
            requestInstanceID == null ? null : "$requestInstanceID",
        "InputFieldID": "$inputFieldID",
        "TextAnswer": textAnswer
      }),
    );

    if (response.statusCode == 200) {
      update(true);
    } else {
      update(false);
      throw Exception("Failed to create input field");
    }
  }

  Future<void> postCreateInputFileFieldInstance(
      int stepInstanceID,
      int requestInstanceID,
      int inputFieldID,
      String base64,
      String fileName,
      Function update) async {
    final http.Response response = await http.post(
      'http://nkkha.somee.com/odata/tbInputFieldInstance',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "StepInstanceID": stepInstanceID == null ? null : "$stepInstanceID",
        "RequestInstanceID":
            requestInstanceID == null ? null : "$requestInstanceID",
        "InputFieldID": "$inputFieldID",
        "FileContent": base64,
        "FileName": fileName
      }),
    );

    if (response.statusCode == 200) {
      update(true);
    } else {
      update(false);
      throw Exception("Failed to create input field");
    }
  }

  Future<List<InputFieldInstance>> getListInputFieldInstance(
      int requestInstanceID, stepInstanceID) async {
    String query = "";
    if (requestInstanceID != null) {
      query = "RequestInstanceID eq $requestInstanceID";
    } else if (stepInstanceID != null) {
      query = "StepInstanceID eq $stepInstanceID";
    }
    final response = await http.get(
        'http://nkkha.somee.com/odata/tbInputFieldInstance/GetInputFieldInstance?\$filter=$query');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['value'];
      List<InputFieldInstance> listInputFieldInstance = new List();
      for (Map i in data) {
        listInputFieldInstance.add(InputFieldInstance.fromJson(i));
      }
      return listInputFieldInstance;
    } else {
      throw Exception('Failed to get list input field!');
    }
  }

  Future<List<NumOfRequestInstance>> getListNumOfRequestInstance() async {
    final response = await http.get(
        'http://nkkha.somee.com/odata/tbRequestInstance/GetNumOfRequestInstance');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['value'];
      List<NumOfRequestInstance> listNumOfRequestInstance = new List();
      for (Map i in data) {
        listNumOfRequestInstance.add(NumOfRequestInstance.fromJson(i));
      }
      return listNumOfRequestInstance;
    } else {
      throw Exception('Failed to get list number of request instance!');
    }
  }

  Future<List<CountRIToday>> getListNumOfRequestInstanceToday() async {
    final response = await http.get(
        'http://nkkha.somee.com/odata/tbRequestInstance/GetNumOfRequestInstanceToday');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['value'];
      List<CountRIToday> listRIToday = new List();
      for (Map i in data) {
        listRIToday.add(CountRIToday.fromJson(i));
      }
      return listRIToday;
    } else {
      throw Exception('Failed to get list number of request instance today!');
    }
  }

  Future<List<RequestInstance>> getListRequestInstance(String query) async {
    List<RequestInstance> listRequestInstance = new List();
    final response = await http.get(
        'http://nkkha.somee.com/odata/tbRequestInstance/GetRequestInstance?$query');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['value'];
      for (Map i in data) {
        if (!RequestInstance.fromJson(i).status.contains('failed')) {
          listRequestInstance.add(RequestInstance.fromJson(i));
        }
      }
      return listRequestInstance;
    } else {
      throw Exception('Failed to load');
    }
  }
}
