// ignore_for_file: unnecessary_getters_setters

import 'package:flutter/material.dart';
import '/backend/schema/structs/index.dart';
import 'flutter_flow/flutter_flow_util.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {}

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  int _introIndex = 0;
  int get introIndex => _introIndex;
  set introIndex(int value) {
    _introIndex = value;
  }

  List<GenderModalStruct> _genderList = [
    GenderModalStruct.fromSerializableMap(jsonDecode(
        '{\"text\":\"Male\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/pj3qhafti0gz/male.png\"}')),
    GenderModalStruct.fromSerializableMap(jsonDecode(
        '{\"text\":\"Female\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/vorqnyivrunt/female.png\"}'))
  ];
  List<GenderModalStruct> get genderList => _genderList;
  set genderList(List<GenderModalStruct> value) {
    _genderList = value;
  }

  void addToGenderList(GenderModalStruct value) {
    _genderList.add(value);
  }

  void removeFromGenderList(GenderModalStruct value) {
    _genderList.remove(value);
  }

  void removeAtIndexFromGenderList(int index) {
    _genderList.removeAt(index);
  }

  void updateGenderListAtIndex(
    int index,
    GenderModalStruct Function(GenderModalStruct) updateFn,
  ) {
    _genderList[index] = updateFn(_genderList[index]);
  }

  void insertAtIndexInGenderList(int index, GenderModalStruct value) {
    _genderList.insert(index, value);
  }

  int _gender = 0;
  int get gender => _gender;
  set gender(int value) {
    _gender = value;
  }

  int _selectPageIndex = 0;
  int get selectPageIndex => _selectPageIndex;
  set selectPageIndex(int value) {
    _selectPageIndex = value;
  }

  List<TodayWorkoutPlanPageStruct> _todayWorkoutPlanList = [
    TodayWorkoutPlanPageStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/3qgrxbc8u3ej/todayWorkout1.png\",\"title\":\"A comprehensive big banded deadlift\",\"rating\":\"4.5\",\"time\":\"30 min\"}')),
    TodayWorkoutPlanPageStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/8rc4yoez4xjp/todayWorkout7.png\",\"title\":\"The high-level athletic workout \",\"rating\":\"4.2\",\"time\":\"25 min\"}')),
    TodayWorkoutPlanPageStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/l48tk9kl8k6e/todayWorkout4.png\",\"title\":\"Build your muscles weight lifting\",\"rating\":\"3.5\",\"time\":\"35 min\"}')),
    TodayWorkoutPlanPageStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/43i1q60rwupw/todayWorkout5.png\",\"title\":\"Kettlebell training to power-ups\",\"rating\":\"3.8\",\"time\":\"45 min\"}')),
    TodayWorkoutPlanPageStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/tom005vpghvh/todayWorkout6.png\",\"title\":\"Barbell training builds strength\",\"rating\":\"4.0\",\"time\":\"40 min\"}')),
    TodayWorkoutPlanPageStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/gxtpe04nrzjj/todayWorkout3.png\",\"title\":\"Simple shoulder workout and fitness \",\"rating\":\"4.1\",\"time\":\"25 min\"}'))
  ];
  List<TodayWorkoutPlanPageStruct> get todayWorkoutPlanList =>
      _todayWorkoutPlanList;
  set todayWorkoutPlanList(List<TodayWorkoutPlanPageStruct> value) {
    _todayWorkoutPlanList = value;
  }

  void addToTodayWorkoutPlanList(TodayWorkoutPlanPageStruct value) {
    _todayWorkoutPlanList.add(value);
  }

  void removeFromTodayWorkoutPlanList(TodayWorkoutPlanPageStruct value) {
    _todayWorkoutPlanList.remove(value);
  }

  void removeAtIndexFromTodayWorkoutPlanList(int index) {
    _todayWorkoutPlanList.removeAt(index);
  }

  void updateTodayWorkoutPlanListAtIndex(
    int index,
    TodayWorkoutPlanPageStruct Function(TodayWorkoutPlanPageStruct) updateFn,
  ) {
    _todayWorkoutPlanList[index] = updateFn(_todayWorkoutPlanList[index]);
  }

  void insertAtIndexInTodayWorkoutPlanList(
      int index, TodayWorkoutPlanPageStruct value) {
    _todayWorkoutPlanList.insert(index, value);
  }

  List<TodayWorkoutPlanPageStruct> _popularWorkoutList = [
    TodayWorkoutPlanPageStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/a0kawqh2mlwj/popularworkout3.png\",\"title\":\"Banded deadlift\",\"rating\":\"4.2\",\"time\":\"35min\"}')),
    TodayWorkoutPlanPageStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/v1kkribjka2m/popularworkout2.png\",\"title\":\"Full body stretching\",\"rating\":\"4.5\",\"time\":\"30min\"}')),
    TodayWorkoutPlanPageStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/87fzteobdhte/popularworkout4.png\",\"title\":\"Cardio exercise\",\"rating\":\"3.8\",\"time\":\"10min\"}')),
    TodayWorkoutPlanPageStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/byw20ame5qpy/popularworkout5.png\",\"title\":\"Muscle exercise\",\"rating\":\"4.8\",\"time\":\"40min\"}')),
    TodayWorkoutPlanPageStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/abfkxmxdw9ya/popularworkout1.png\",\"title\":\"Strength training\",\"rating\":\"3.5\",\"time\":\"18min\"}')),
    TodayWorkoutPlanPageStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/3mlukchj8m6s/popularworkout6.png\",\"title\":\"Chest workout\",\"rating\":\"3.6\",\"time\":\"20min\"}')),
    TodayWorkoutPlanPageStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/4jzviaouuozg/popularworkout7.png\",\"title\":\"Banded deadlift\",\"rating\":\"4.1\",\"time\":\"25min\"}')),
    TodayWorkoutPlanPageStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/mjur2rj3jxux/popularworkout8.png\",\"title\":\"Full body stretching\",\"rating\":\"4.3\",\"time\":\"25min\"}'))
  ];
  List<TodayWorkoutPlanPageStruct> get popularWorkoutList =>
      _popularWorkoutList;
  set popularWorkoutList(List<TodayWorkoutPlanPageStruct> value) {
    _popularWorkoutList = value;
  }

  void addToPopularWorkoutList(TodayWorkoutPlanPageStruct value) {
    _popularWorkoutList.add(value);
  }

  void removeFromPopularWorkoutList(TodayWorkoutPlanPageStruct value) {
    _popularWorkoutList.remove(value);
  }

  void removeAtIndexFromPopularWorkoutList(int index) {
    _popularWorkoutList.removeAt(index);
  }

  void updatePopularWorkoutListAtIndex(
    int index,
    TodayWorkoutPlanPageStruct Function(TodayWorkoutPlanPageStruct) updateFn,
  ) {
    _popularWorkoutList[index] = updateFn(_popularWorkoutList[index]);
  }

  void insertAtIndexInPopularWorkoutList(
      int index, TodayWorkoutPlanPageStruct value) {
    _popularWorkoutList.insert(index, value);
  }

  List<EpisodeModelStruct> _episodeList = [
    EpisodeModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/ydxweqnu59ru/episode1.png\",\"title\":\"Squats 13x2\",\"playText\":\"15 m 10 s\"}')),
    EpisodeModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/ydxweqnu59ru/episode1.png\",\"title\":\"Squats 13x2\",\"playText\":\"15 m 10 s\"}')),
    EpisodeModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/ydxweqnu59ru/episode1.png\",\"title\":\"Squats 13x2\",\"playText\":\"15 m 10 s\"}')),
    EpisodeModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/uifmnjah323b/episode2.png\",\"title\":\"Jumping rope 15x2\",\"playText\":\"10 m 00 s\"}'))
  ];
  List<EpisodeModelStruct> get episodeList => _episodeList;
  set episodeList(List<EpisodeModelStruct> value) {
    _episodeList = value;
  }

  void addToEpisodeList(EpisodeModelStruct value) {
    _episodeList.add(value);
  }

  void removeFromEpisodeList(EpisodeModelStruct value) {
    _episodeList.remove(value);
  }

  void removeAtIndexFromEpisodeList(int index) {
    _episodeList.removeAt(index);
  }

  void updateEpisodeListAtIndex(
    int index,
    EpisodeModelStruct Function(EpisodeModelStruct) updateFn,
  ) {
    _episodeList[index] = updateFn(_episodeList[index]);
  }

  void insertAtIndexInEpisodeList(int index, EpisodeModelStruct value) {
    _episodeList.insert(index, value);
  }

  List<NotificationModelStruct> _notificationList = [
    NotificationModelStruct.fromSerializableMap(jsonDecode(
        '{\"title\":\"Achieve your fitness goals\",\"subTitle\":\"Unleash your full potential with these expert tips\",\"time\":\"30 seconds ago\"}')),
    NotificationModelStruct.fromSerializableMap(jsonDecode(
        '{\"title\":\"Fitness revolution\",\"subTitle\":\"Transform your body and mind with these proven workouts\",\"time\":\"5 mins ago\"}')),
    NotificationModelStruct.fromSerializableMap(jsonDecode(
        '{\"title\":\"Get fit, stay strong\",\"subTitle\":\"Discover effective strategies to achieve and maintain your fitness\",\"time\":\"20 mins ago\"}')),
    NotificationModelStruct.fromSerializableMap(jsonDecode(
        '{\"title\":\"Fitness game\",\"subTitle\":\"Take on new challenges and break through your limits\",\"time\":\"1 hour ago\"}')),
    NotificationModelStruct.fromSerializableMap(jsonDecode(
        '{\"title\":\"Fuel your body\",\"subTitle\":\"Enjoy your journey to a healthier lifestyle with exciting workout routines\",\"time\":\"a few seconds ago\"}'))
  ];
  List<NotificationModelStruct> get notificationList => _notificationList;
  set notificationList(List<NotificationModelStruct> value) {
    _notificationList = value;
  }

  void addToNotificationList(NotificationModelStruct value) {
    _notificationList.add(value);
  }

  void removeFromNotificationList(NotificationModelStruct value) {
    _notificationList.remove(value);
  }

  void removeAtIndexFromNotificationList(int index) {
    _notificationList.removeAt(index);
  }

  void updateNotificationListAtIndex(
    int index,
    NotificationModelStruct Function(NotificationModelStruct) updateFn,
  ) {
    _notificationList[index] = updateFn(_notificationList[index]);
  }

  void insertAtIndexInNotificationList(
      int index, NotificationModelStruct value) {
    _notificationList.insert(index, value);
  }

  List<ReportModelStruct> _reportList = [
    ReportModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/ecp9c2qk6t20/heartRateReport.png\",\"title\":\"Heart rate\",\"subTitle\":\"90 dbm\"}')),
    ReportModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/tl9atfuhcs08/running.png\",\"title\":\"Steps\",\"subTitle\":\"2500 steps\"}')),
    ReportModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/ix75ew14ep1l/sleep.png\",\"title\":\"Sleep\",\"subTitle\":\"08 hours\"}')),
    ReportModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/pse7w9rwkreo/steps.png\",\"title\":\"Running\",\"subTitle\":\"7.8km\"}'))
  ];
  List<ReportModelStruct> get reportList => _reportList;
  set reportList(List<ReportModelStruct> value) {
    _reportList = value;
  }

  void addToReportList(ReportModelStruct value) {
    _reportList.add(value);
  }

  void removeFromReportList(ReportModelStruct value) {
    _reportList.remove(value);
  }

  void removeAtIndexFromReportList(int index) {
    _reportList.removeAt(index);
  }

  void updateReportListAtIndex(
    int index,
    ReportModelStruct Function(ReportModelStruct) updateFn,
  ) {
    _reportList[index] = updateFn(_reportList[index]);
  }

  void insertAtIndexInReportList(int index, ReportModelStruct value) {
    _reportList.insert(index, value);
  }

  List<String> _chartLabal = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  List<String> get chartLabal => _chartLabal;
  set chartLabal(List<String> value) {
    _chartLabal = value;
  }

  void addToChartLabal(String value) {
    _chartLabal.add(value);
  }

  void removeFromChartLabal(String value) {
    _chartLabal.remove(value);
  }

  void removeAtIndexFromChartLabal(int index) {
    _chartLabal.removeAt(index);
  }

  void updateChartLabalAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    _chartLabal[index] = updateFn(_chartLabal[index]);
  }

  void insertAtIndexInChartLabal(int index, String value) {
    _chartLabal.insert(index, value);
  }

  List<String> _chartValue = ['0', '1k', '2k', '3k', '4k', '5k', '6k'];
  List<String> get chartValue => _chartValue;
  set chartValue(List<String> value) {
    _chartValue = value;
  }

  void addToChartValue(String value) {
    _chartValue.add(value);
  }

  void removeFromChartValue(String value) {
    _chartValue.remove(value);
  }

  void removeAtIndexFromChartValue(int index) {
    _chartValue.removeAt(index);
  }

  void updateChartValueAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    _chartValue[index] = updateFn(_chartValue[index]);
  }

  void insertAtIndexInChartValue(int index, String value) {
    _chartValue.insert(index, value);
  }

  List<ResentWokoutModelStruct> _recentWorkout = [
    ResentWokoutModelStruct.fromSerializableMap(jsonDecode(
        '{\"title\":\"Back workout\",\"subText\":\"600 kcal\",\"time\":\"20min\"}')),
    ResentWokoutModelStruct.fromSerializableMap(jsonDecode(
        '{\"title\":\"Full body workout\",\"subText\":\"350 kcal\",\"time\":\"40min\"}')),
    ResentWokoutModelStruct.fromSerializableMap(jsonDecode(
        '{\"title\":\"Back body workout\",\"subText\":\"400 kcal\",\"time\":\"35min\"}')),
    ResentWokoutModelStruct.fromSerializableMap(jsonDecode(
        '{\"title\":\"Chest workout\",\"subText\":\"450 kcal\",\"time\":\"10min\"}')),
    ResentWokoutModelStruct.fromSerializableMap(jsonDecode(
        '{\"title\":\"Outdoor cycle\",\"subText\":\"800 kcal\",\"time\":\"28min\"}')),
    ResentWokoutModelStruct.fromSerializableMap(jsonDecode(
        '{\"title\":\"Running\",\"subText\":\"688 kcal\",\"time\":\"40min\"}')),
    ResentWokoutModelStruct.fromSerializableMap(jsonDecode(
        '{\"title\":\"Morning walking\",\"subText\":\"1200 kcal\",\"time\":\"35min\"}')),
    ResentWokoutModelStruct.fromSerializableMap(jsonDecode(
        '{\"title\":\"Back workout\",\"subText\":\"300 kcal\",\"time\":\"20min\"}'))
  ];
  List<ResentWokoutModelStruct> get recentWorkout => _recentWorkout;
  set recentWorkout(List<ResentWokoutModelStruct> value) {
    _recentWorkout = value;
  }

  void addToRecentWorkout(ResentWokoutModelStruct value) {
    _recentWorkout.add(value);
  }

  void removeFromRecentWorkout(ResentWokoutModelStruct value) {
    _recentWorkout.remove(value);
  }

  void removeAtIndexFromRecentWorkout(int index) {
    _recentWorkout.removeAt(index);
  }

  void updateRecentWorkoutAtIndex(
    int index,
    ResentWokoutModelStruct Function(ResentWokoutModelStruct) updateFn,
  ) {
    _recentWorkout[index] = updateFn(_recentWorkout[index]);
  }

  void insertAtIndexInRecentWorkout(
      int index, ResentWokoutModelStruct value) {
    _recentWorkout.insert(index, value);
  }

  int _selectYourGoal = 1;
  int get selectYourGoal => _selectYourGoal;
  set selectYourGoal(int value) {
    _selectYourGoal = value;
  }

  List<GoalsModelStruct> _goalsList = [
    GoalsModelStruct.fromSerializableMap(jsonDecode(
        '{\"unselectImage\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/8rbrur38w3yb/solidHeadHeart.png\",\"selectImage\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/idziqel87fwj/weightSelected.png\",\"checkSelect\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/0efpwhgx1ynl/checkbox.png\",\"checkUnSelect\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/4s56geyceecx/checkboxEmpty.png\",\"text\":\"I wanna get more strength\"}')),
    GoalsModelStruct.fromSerializableMap(jsonDecode(
        '{\"unselectImage\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/bsgm0028xmst/unSelectHead.png\",\"selectImage\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/l6hgx3jmvxr1/Solid_head_heart.png\",\"checkSelect\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/0efpwhgx1ynl/checkbox.png\",\"checkUnSelect\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/4s56geyceecx/checkboxEmpty.png\",\"text\":\"I wanna lose weight\"}')),
    GoalsModelStruct.fromSerializableMap(jsonDecode(
        '{\"unselectImage\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/imq5j4tecxwt/unselectHeard.png\",\"selectImage\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/5z0ardjllevr/selectHeard.png\",\"checkSelect\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/0efpwhgx1ynl/checkbox.png\",\"checkUnSelect\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/4s56geyceecx/checkboxEmpty.png\",\"text\":\"I wanna get bulks\"}')),
    GoalsModelStruct.fromSerializableMap(jsonDecode(
        '{\"unselectImage\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/05qz3cb9u1h9/unselectHealth.png\",\"selectImage\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/glb57mhy2bbl/health.png\",\"checkSelect\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/0efpwhgx1ynl/checkbox.png\",\"checkUnSelect\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/4s56geyceecx/checkboxEmpty.png\",\"text\":\"I wanna gain endurance\"}'))
  ];
  List<GoalsModelStruct> get goalsList => _goalsList;
  set goalsList(List<GoalsModelStruct> value) {
    _goalsList = value;
  }

  void addToGoalsList(GoalsModelStruct value) {
    _goalsList.add(value);
  }

  void removeFromGoalsList(GoalsModelStruct value) {
    _goalsList.remove(value);
  }

  void removeAtIndexFromGoalsList(int index) {
    _goalsList.removeAt(index);
  }

  void updateGoalsListAtIndex(
    int index,
    GoalsModelStruct Function(GoalsModelStruct) updateFn,
  ) {
    _goalsList[index] = updateFn(_goalsList[index]);
  }

  void insertAtIndexInGoalsList(int index, GoalsModelStruct value) {
    _goalsList.insert(index, value);
  }

  int _updatePageAge = 0;
  int get updatePageAge => _updatePageAge;
  set updatePageAge(int value) {
    _updatePageAge = value;
  }

  int _updateHeight = 0;
  int get updateHeight => _updateHeight;
  set updateHeight(int value) {
    _updateHeight = value;
  }

  String _selectWeight = '';
  String get selectWeight => _selectWeight;
  set selectWeight(String value) {
    _selectWeight = value;
  }
}
