class PredictionModel{
  String? placeid;
  String? maintext;
  String? secondarytext;

  PredictionModel({this.placeid, this.maintext, this.secondarytext});
  PredictionModel.fromJson(Map<String, dynamic> json){
    placeid = json["place_id"];
    maintext = json["structured_formatting"]["main_text"];
    secondarytext = json["structured_formatting"]["secondary_text"];
  }
}