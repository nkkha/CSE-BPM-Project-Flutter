import 'dart:async';
import 'dart:convert';

import 'package:cse_bpm_project/model/CountRIToday.dart';
import 'package:cse_bpm_project/model/DeviceToken.dart';
import 'package:cse_bpm_project/model/DropdownOption.dart';
import 'package:cse_bpm_project/model/InputField.dart';
import 'package:cse_bpm_project/model/InputFieldInstance.dart';
import 'package:cse_bpm_project/model/NumOfRequestInstance.dart';
import 'package:cse_bpm_project/model/RequestInstance.dart';
import 'package:cse_bpm_project/model/Role.dart';
import 'package:cse_bpm_project/model/Step.dart';
import 'package:cse_bpm_project/model/StepInstance.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final DateFormat formatterDateTime = DateFormat('yyyy-MM-ddThh:mm:ss+07:00');

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
      throw Exception('Failed to update request');
    }
  }

  ///

  // StepInstance
  Future<List<StepInstance>> getStepInstances(
      int tabIndex, int requestInstanceID) async {
    final response = await http.get(
        'http://nkkha.somee.com/odata/tbStepInstance/GetStepInstanceDetails?\$filter=StepIndex eq $tabIndex and RequestInstanceID eq $requestInstanceID&\$orderby=StepID asc');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['value'];
      List<StepInstance> listStepInstance = [];
      for (Map i in data) {
        listStepInstance.add(StepInstance.fromJson(i));
      }
      return listStepInstance;
    } else {
      throw Exception('Failed to load');
    }
  }

  Future<List<StepInstance>> getStepInstancesByQuery(String query) async {
    final response = await http.get(
        'http://nkkha.somee.com/odata/tbStepInstance/GetStepInstanceDetails?$query');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['value'];
      List<StepInstance> listStepInstance = [];
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
      List<MyStep> listStep = [];
      for (Map i in data) {
        listStep.add(MyStep.fromJson(i));
      }
      nextStepSize = listStep.length;
      for (int i = 0; i < nextStepSize; i++) {
        postCreateNextStepInstances(
            requestInstance.id, listStep[i].id, (data) => update(data));
      }
      if (nextStepSize == 0) {
        update(false);
      }
    } else {
      throw Exception('Failed to load');
    }
  }

  Future<List<MyStep>> getStepByID(int id) async {
    final response = await http
        .get('http://nkkha.somee.com/odata/tbStep?\$filter=RequestID eq $id');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['value'];
      List<MyStep> listStep = [];
      for (Map i in data) {
        listStep.add(MyStep.fromJson(i));
      }

      return listStep;
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
      List<StepInstance> listStepInstance = [];
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
    String createdDate = formatterDateTime.format(DateTime.now());

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
        "ResponseMessage": "",
        "CreatedDate": createdDate
      }),
    );

    if (response.statusCode == 200) {
      count++;
      if (count == nextStepSize) {
        update(true);
      }
    } else {
      update(false);
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
      MyStep step = MyStep.fromJson(jsonDecode(response.body));
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
      List<Role> listRole = [];
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
      int inputFieldTypeID, String title, int index, Function update) async {
    final http.Response response = await http.post(
      'http://nkkha.somee.com/odata/tbInputField',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "StepID": stepID == null ? null : "$stepID",
        "RequestID": requestID == null ? null : "$requestID",
        "InputFieldTypeID": "$inputFieldTypeID",
        "Title": title,
        "IpIndex": "$index"
      }),
    );

    if (response.statusCode == 200) {
      final inputFieldID = jsonDecode(response.body)['ID'];
      update(true, inputFieldID);
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
    final response = await http.get(
        'http://nkkha.somee.com/odata/tbInputField?\$filter=$query&\$orderby=IpIndex asc');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['value'];
      List<InputField> listInputField = [];
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
      String url,
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
        "FileUrl": url,
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
        'http://nkkha.somee.com/odata/tbInputFieldInstance/GetInputFieldInstance?\$filter=$query&\$orderby=IpIndex asc');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['value'];
      List<InputFieldInstance> listInputFieldInstance = [];
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
      List<NumOfRequestInstance> listNumOfRequestInstance = [];
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
      List<CountRIToday> listRIToday = [];
      for (Map i in data) {
        listRIToday.add(CountRIToday.fromJson(i));
      }
      return listRIToday;
    } else {
      throw Exception('Failed to get list number of request instance today!');
    }
  }

  Future<List<RequestInstance>> getListRequestInstance(String query) async {
    List<RequestInstance> listRequestInstance = [];
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

  Future<void> postDeviceToken(
      int userID, String deviceToken, bool isLogin) async {
    final http.Response response = await http.post(
      'http://nkkha.somee.com/odata/tbDeviceToken',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "UserID": "$userID",
        "DeviceToken": deviceToken,
        "IsLogin": "$isLogin"
      }),
    );

    if (response.statusCode == 200) {
      print('Post device token successfully.');
      final data = jsonDecode(response.body);
      DeviceToken deviceToken = DeviceToken.fromJson(data);
      final prefs = await SharedPreferences.getInstance();
      prefs.setInt('deviceTokenID', deviceToken.id);
    } else {
      throw Exception('Failed to create next step instances.');
    }
  }

  Future<void> updateDeviceToken() async {
    final prefs = await SharedPreferences.getInstance();
    int deviceTokenID = prefs.getInt("deviceTokenID");

    var resBody = {};
    resBody["IsLogin"] = "false";
    String str = json.encode(resBody);

    final http.Response response = await http.patch(
      'http://nkkha.somee.com/odata/tbDeviceToken($deviceTokenID)',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: str,
    );

    if (response.statusCode == 200) {
      print('Post device token successfully.');
      final prefs = await SharedPreferences.getInstance();
      prefs.clear();
    } else {
      throw Exception('Failed to update device token.');
    }
  }

  //DropdownOptions

  Future<void> postCreateDropdownOptions(String data) async {
    final http.Response response = await http.post(
      'http://nkkha.somee.com/odata/tbDropdownOption/PostListEntity',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{"value": data}),
    );

    if (response.statusCode == 200) {
    } else {
      throw Exception("Failed to create dropdown options");
    }
  }

  Future<List<DropdownOption>> getDropdownOptions(int inputFieldID) async {
    final response = await http.get(
        'http://nkkha.somee.com/odata/tbDropdownOption?\$filter=InputFieldID eq $inputFieldID');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['value'];
      List<DropdownOption> listDropdownOption = [];
      for (Map i in data) {
        listDropdownOption.add(DropdownOption.fromJson(i));
      }
      return listDropdownOption;
    } else {
      throw Exception('Failed to load');
    }
  }
}
