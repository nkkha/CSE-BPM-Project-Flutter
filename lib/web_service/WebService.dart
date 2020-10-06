import 'dart:async';
import 'dart:convert';
import 'package:cse_bpm_project/model/RequestInstance.dart';
import 'package:cse_bpm_project/model/Role.dart';
import 'package:cse_bpm_project/model/Step.dart';
import 'package:http/http.dart' as http;

import 'package:cse_bpm_project/model/StepInstance.dart';

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

  /// Web API

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
      getNextStep(
          requestInstance, requestInstance.currentStepIndex + 1, update);
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

  Future<void> getOtherCurrentStepInstances(RequestInstance requestInstance, int currentStepInstanceID, int currentStepIndex,
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
        if (listStepInstance[i].status.contains('active') || listStepInstance[i].status.contains('failed')) {
          isCompleted = false;
          update(false);
          break;
        }
      }
      if (isCompleted) {
        patchRequestInstanceStepIndex(requestInstance, update);
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

  Future<void> postCreateStep(
      String requestID, String description, int approverRoleID, int stepIndex, Function update) async {
    final http.Response response = await http.post(
      'http://nkkha.somee.com/odata/tbStep',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "RequestID": "3",
        "Description": "$description",
        "ApproverRoleID": "$approverRoleID",
        "StepIndex": "$stepIndex"
      }),
    );

    if (response.statusCode == 200) {
      update(true);
    } else {
      throw Exception('Failed to create next step instances.');
    }
  }

  /// Role

  Future<List<Role>> getRole() async {
    final response = await http.get(
        'http://nkkha.somee.com/odata/tbRole');

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

  /// StepInputField

  Future<void> postCreateStepInputField(
      int stepID, String requestID, int inputFieldID, String title, Function update) async {
    final http.Response response = await http.post(
      'http://nkkha.somee.com/odata/tbStepInputField',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "StepID": "$stepID",
        "RequestID": requestID,
        "InputFieldID": "$inputFieldID",
        "Title": title
      }),
    );

    if (response.statusCode == 200) {
      update(true);
    } else {
      throw Exception("Failed to create step input field");
    }
  }
}
