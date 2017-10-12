import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mvc/flutter_mvc.dart';
import 'package:vanilla/models.dart';
import 'package:vanilla/localization.dart';
import 'package:vanilla/widgets/extra_actions_button.dart';
import 'package:vanilla/widgets/filter_button.dart';
import 'package:vanilla/widgets/stats_counter.dart';
import 'package:vanilla/widgets/todo_list.dart';
import 'package:vanilla/widgets/typedefs.dart';

class TabsScreen extends StatefulWidget {
  final AppState appState;
  final TodoAdder addTodo;
  final TodoRemover removeTodo;
  final TodoUpdater updateTodo;
  final Function toggleAll;
  final Function clearCompleted;

  TabsScreen({
    @required this.appState,
    @required this.addTodo,
    @required this.removeTodo,
    @required this.updateTodo,
    @required this.toggleAll,
    @required this.clearCompleted,
    Key key,
  })
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new TabsScreenState();
  }
}

class TabsScreenState extends State<TabsScreen> {
  VisibilityFilter activeFilter = VisibilityFilter.all;
  AppTab activeTab = AppTab.todos;

  _updateVisibility(VisibilityFilter filter) {
    setState(() {
      activeFilter = filter;
    });
  }

  _updateTab(AppTab tab) {
    setState(() {
      activeTab = tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(VanillaLocalizations.of(context).appTitle),
        actions: [
          new FilterButton(
            isActive: activeTab == AppTab.todos,
            activeFilter: activeFilter,
            onSelected: _updateVisibility,
          ),
          new ExtraActionsButton(
            allComplete: widget.appState.allComplete,
            hasCompletedTodos: widget.appState.hasCompletedTodos,
            onSelected: (action) {
              if (action == ExtraAction.toggleAllComplete) {
                widget.toggleAll();
              } else if (action == ExtraAction.clearCompleted) {
                widget.clearCompleted();
              }
            },
          )
        ],
      ),
      body: activeTab == AppTab.todos
          ? new TodoList(
              filteredTodos: widget.appState.filteredTodos(activeFilter),
              loading: widget.appState.isLoading,
              removeTodo: widget.removeTodo,
              addTodo: widget.addTodo,
              updateTodo: widget.updateTodo,
            )
          : new StatsCounter(
              numActive: widget.appState.numActive,
              numCompleted: widget.appState.numCompleted,
            ),
      floatingActionButton: new FloatingActionButton(
        key: FlutterMvcKeys.addTodoFab,
        onPressed: () {
          Navigator.pushNamed(context, FlutterMvcRoutes.addTodo);
        },
        child: new Icon(Icons.add),
        tooltip: ArchitectureLocalizations.of(context).addTodo,
      ),
      bottomNavigationBar: new BottomNavigationBar(
        key: FlutterMvcKeys.tabs,
        currentIndex: AppTab.values.indexOf(activeTab),
        onTap: (index) {
          _updateTab(AppTab.values[index]);
        },
        items: AppTab.values.map((tab) {
          return new BottomNavigationBarItem(
            icon: new Icon(tab == AppTab.todos ? Icons.list : Icons.show_chart),
            title: new Text(tab == AppTab.stats
                ? ArchitectureLocalizations.of(context).stats
                : ArchitectureLocalizations.of(context).todos),
          );
        }).toList(),
      ),
    );
  }
}