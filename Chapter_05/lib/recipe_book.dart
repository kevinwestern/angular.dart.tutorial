library recipe_book_controller;

import 'package:angular/angular.dart';

import 'recipe.dart';
import 'tooltip/tooltip_directive.dart';

@NgController(
    selector: '[recipe-book]',
    publishAs: 'ctrl')
class RecipeBookController {

  static const String LOADING_MESSAGE = "Loading recipe book...";
  static const String ERROR_MESSAGE = """Sorry! The cook stepped out of the 
kitchen and took the recipe book with him!""";

  Http _http;

  // Determine the initial load state of the app
  String message = LOADING_MESSAGE;
  bool recipesLoaded = false;
  bool categoriesLoaded = false;

  // Data objects that are loaded from the server side via json
  List categories = [];
  List<Recipe> recipes = [];

  // Filter box
  Map<String, bool> categoryFilterMap = {};
  String nameFilterString = "";

  RecipeBookController(Http this._http) {
    _loadData();
  }

  Recipe selectedRecipe;

  void selectRecipe(Recipe recipe) {
    selectedRecipe = recipe;
  }

  // Tooltip
  static final tooltip = new Expando<TooltipModel>();
  TooltipModel tooltipForRecipe(Recipe recipe) {
    if (tooltip[recipe] == null) {
      tooltip[recipe] = new TooltipModel(recipe.imgUrl,
          "I don't have a picture of these recipes, "
          "so here's one of my cat instead!",
          80);
    }
    return tooltip[recipe]; // recipe.tooltip
  }

  void clearFilters() {
    categoryFilterMap.keys.forEach((f) => categoryFilterMap[f] = false);
    nameFilterString = "";
  }

  void _loadData() {
    recipesLoaded = false;
    categoriesLoaded = false;
    _http.get('recipes.json')
      .then((HttpResponse response) {
      print(response);
        for (Map recipe in response.data) {
          recipes.add(new Recipe.fromJsonMap(recipe));
        }
        recipesLoaded = true;
      },
      onError: (Object obj) {
        print(obj);
        recipesLoaded = false;
        message = ERROR_MESSAGE;
      });

    _http.get('categories.json')
        .then((HttpResponse response) {
      print(response);
      for (String category in response.data) {
        categories.add(category);
        categoryFilterMap[category] = false;
      }
      categoriesLoaded = true;
    },
    onError: (Object obj) {
      print(obj);
      categoriesLoaded = false;
      message = ERROR_MESSAGE;
    });
  }
}
