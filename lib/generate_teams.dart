import 'dart:math';

import 'package:dream11_predictor/common.dart';
import 'package:dream11_predictor/players_info.dart';
import 'package:dream11_predictor/teams_filter.dart';
import 'package:dream11_predictor/widgets/circular_loader.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class GenerateTeamsModel {
  PlayersFilterModel filters;
  List<PlayerInfoModel> players;
  final TeamModel teamA;
  final TeamModel teamB;

  GenerateTeamsModel({
    required this.filters,
    required this.players,
    required this.teamA,
    required this.teamB,
  });
}

Future<List<TeamModel>> _generateTeams(GenerateTeamsModel args) async {
  List<TeamModel> _teams = [];
  // Generating the Teams based on the filters

  //Considering the team combinations

  //removing the excluded players
  List<String> excludedPlayers =
      args.filters.excludedPlayers.map((e) => e.name).toList(growable: false);

  args.players = args.players
      .where((element) => !excludedPlayers.contains(element.name))
      .toList();

  print("Generating teams by excluding $excludedPlayers");

  //Generating the all possible combinations
  List teams = getSizedSubsets(args.players, 11);

  print("Total Teams: ${teams.length}");

  //Picking the teams whose total credits are in between 94 & 100
  teams = teams.where((element) {
    var totalCredits = (element)
        .map((player) => (player as PlayerInfoModel).credits)
        .reduce((a, b) => a + b);
    return totalCredits >= 94.5 && totalCredits <= 100;
  }).toList();

  print('Teams after applying credits filter: ${teams.length}');

  // picking the teams with _filters.teamCombinations
  var tmpTeams = [];
  for (var combination in args.filters.teamCombinations) {
    int teamAPlayersCount = combination[0];
    int teamBPlayersCount = combination[1];

    tmpTeams.addAll(
      teams.where((element) {
        int noOfPlayersFromTeamA = (element)
            .where(
                (player) => (player as PlayerInfoModel).team == args.teamA.name)
            .length;
        int noOfPlayersFromTeamB = (element)
            .where(
                (player) => (player as PlayerInfoModel).team == args.teamB.name)
            .length;

        return teamAPlayersCount == noOfPlayersFromTeamA &&
            teamBPlayersCount == noOfPlayersFromTeamB;
      }).toList(),
    );
  }

  teams = [...tmpTeams];

  print('Teams after applying team combination filter: ${teams.length}');

  //Applying the Wicket Keepers Range filter
  teams = teams.where((element) {
    int noOfWicketKeepers = (element)
        .where((player) =>
            (player as PlayerInfoModel).type == PlayerType.wicketKeeper)
        .length;
    return noOfWicketKeepers >= args.filters.wicketKeepersRange.start &&
        noOfWicketKeepers <= args.filters.wicketKeepersRange.end;
  }).toList();

  print('Teams after applying wicket keepers range filter: ${teams.length}');

  //Applying the All Rounders Range filter
  teams = teams.where((element) {
    int noOfAllRounders = (element)
        .where((player) =>
            (player as PlayerInfoModel).type == PlayerType.allRounder)
        .length;
    return noOfAllRounders >= args.filters.allRoundersRange.start &&
        noOfAllRounders <= args.filters.allRoundersRange.end;
  }).toList();

  print('Teams after applying all rounders range filter: ${teams.length}');

  //Applying the Batsmen Range filter
  teams = teams.where((element) {
    int noOfBatsmen = (element)
        .where(
            (player) => (player as PlayerInfoModel).type == PlayerType.batsman)
        .length;
    return noOfBatsmen >= args.filters.batsmenRange.start &&
        noOfBatsmen <= args.filters.batsmenRange.end;
  }).toList();

  print('Teams after applying batsmen range filter: ${teams.length}');

  //Applying the Bowlers Range filter
  teams = teams.where((element) {
    int noOfBowlers = (element)
        .where(
            (player) => (player as PlayerInfoModel).type == PlayerType.bowler)
        .length;
    return noOfBowlers >= args.filters.bowlersRange.start &&
        noOfBowlers <= args.filters.bowlersRange.end;
  }).toList();

  print('Teams after applying bowlers range filter: ${teams.length}');

  //Removing
  teams = teams.where((element) {
    int noOfbatsMenFromTeamA = (element)
        .where((player) => (player as PlayerInfoModel).team == args.teamA.name)
        .where(
            (player) => (player as PlayerInfoModel).type == PlayerType.batsman)
        .length;
    int noOfBowlersFromTeamA = (element)
        .where((player) => (player as PlayerInfoModel).team == args.teamA.name)
        .where(
            (player) => (player as PlayerInfoModel).type == PlayerType.bowler)
        .length;
    int noOfbatsMenFromTeamB = (element)
        .where((player) => (player as PlayerInfoModel).team == args.teamB.name)
        .where(
            (player) => (player as PlayerInfoModel).type == PlayerType.batsman)
        .length;
    int noOfBowlersFromTeamB = (element)
        .where((player) => (player as PlayerInfoModel).team == args.teamB.name)
        .where(
            (player) => (player as PlayerInfoModel).type == PlayerType.bowler)
        .length;

    int noOfWicketKeepersFromTeamA = (element)
        .where((player) => (player as PlayerInfoModel).team == args.teamA.name)
        .where((player) =>
            (player as PlayerInfoModel).type == PlayerType.wicketKeeper)
        .length;

    int noOfWicketKeepersFromTeamB = (element)
        .where((player) => (player as PlayerInfoModel).team == args.teamB.name)
        .where((player) =>
            (player as PlayerInfoModel).type == PlayerType.wicketKeeper)
        .length;

    int noOfAllRoundersFromTeamA = (element)
        .where((player) => (player as PlayerInfoModel).team == args.teamA.name)
        .where((player) =>
            (player as PlayerInfoModel).type == PlayerType.allRounder)
        .length;
    int noOfAllRoundersFromTeamB = (element)
        .where((player) => (player as PlayerInfoModel).team == args.teamB.name)
        .where((player) =>
            (player as PlayerInfoModel).type == PlayerType.allRounder)
        .length;

    return noOfbatsMenFromTeamA <= 3 &&
        noOfBowlersFromTeamA <= 3 &&
        noOfbatsMenFromTeamB <= 3 &&
        noOfBowlersFromTeamB <= 3 &&
        noOfWicketKeepersFromTeamA <= 2 &&
        noOfWicketKeepersFromTeamB <= 2 &&
        noOfAllRoundersFromTeamA <= 3 &&
        noOfAllRoundersFromTeamB <= 3;
  }).toList();

  print(
      'Teams after applying batsmen(<=3), bowlers(<=3), wicket keepers (<=2) and All Rounders(<=3) count filter: ${teams.length}');

  _teams = teams.map<TeamModel>((element) {
    List<PlayerInfoModel> team =
        (element as List).map<PlayerInfoModel>((player) {
      return player as PlayerInfoModel;
    }).toList();

    return TeamModel(
      name: 'Team ${teams.indexOf(element) + 1}',
      batsmen:
          team.where((player) => player.type == PlayerType.batsman).toList(),
      bowlers:
          team.where((player) => player.type == PlayerType.bowler).toList(),
      allRounders:
          team.where((player) => player.type == PlayerType.allRounder).toList(),
      wicketKeepers: team
          .where((player) => player.type == PlayerType.wicketKeeper)
          .toList(),
    );
  }).toList();

  print('Teams after applying all filters: ${_teams.length}');

  return _teams;
}

List getSizedSubsets(List l, int size) =>
    getAllSubsets(l).where((element) => element.length == size).toList();

List getAllSubsets(List l) => l.fold<List>(
      [[]],
      (subLists, element) {
        return subLists
            .map((subList) => [
                  subList,
                  subList + [element]
                ])
            .expand((element) => element)
            .toList();
      },
    );

class TeamModel {
  final String name;

  final List<PlayerInfoModel> batsmen; // value ranges from 3 to 6
  final List<PlayerInfoModel> bowlers; // value ranges from 3 to 6
  final List<PlayerInfoModel> allRounders; // value ranges from 1 to 4
  final List<PlayerInfoModel> wicketKeepers; // value ranges from 1 to 4

  TeamModel({
    required this.name,
    required this.batsmen,
    required this.bowlers,
    required this.allRounders,
    required this.wicketKeepers,
  });
}

class GenerateTeams extends StatefulWidget {
  final List<PlayerInfoModel> players;
  final PlayersFilterModel filters;
  final TeamModel teamA;
  final TeamModel teamB;

  const GenerateTeams({
    Key? key,
    required this.players,
    required this.filters,
    required this.teamA,
    required this.teamB,
  }) : super(key: key);

  @override
  State<GenerateTeams> createState() => _GenerateTeamsState();
}

class _GenerateTeamsState extends State<GenerateTeams>
    with SingleTickerProviderStateMixin {
  late List<TeamModel> _teams;
  bool _isLoading = true;
  late TabController _tabController;
  late PlayersFilterModel _filters = widget.filters;

  late final GenerateTeamsModel args;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    args = GenerateTeamsModel(
      teamA: widget.teamA,
      teamB: widget.teamB,
      filters: _filters,
      players: widget.players,
    );

    _teams = await compute(_generateTeams, args);
    _tabController = TabController(
      length: _teams.length,
      vsync: this,
    );
    _isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Container(
            color: Colors.white,
            child: const Center(
              child: CircularLoader(),
            ),
          )
        : DefaultTabController(
            length: _tabController.length,
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Teams'),
                elevation: 0,
                titleSpacing: 0.0,
                actions: [
                  IconButton(
                    onPressed: () async {
                      PlayersFilterModel? filters = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TeamsFilter(
                            teamA: widget.teamA,
                            teamB: widget.teamB,
                            previousFilters: _filters,
                          ),
                        ),
                      );

                      if (filters != null) {
                        _filters = filters;
                        args.filters = filters;
                        _teams = await compute(_generateTeams, args);
                        setState(() {});
                      }
                    },
                    icon: const Icon(
                      Icons.filter_alt,
                    ),
                  )
                ],
                bottom: TabBar(
                  physics: const BouncingScrollPhysics(),
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.white,
                  onTap: (i) {
                    _tabController.animateTo(i);
                  },
                  indicatorSize: TabBarIndicatorSize.label,
                  isScrollable: true,
                  controller: _tabController,
                  indicator: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    color: Colors.white,
                  ),
                  tabs: _teams.map((team) {
                    return Tab(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(defaultRadius),
                        ),
                        child: Text(
                          'Team ${_teams.indexOf(team) + 1}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              body: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: _teams.map((team) {
                  return _buildTeam(team);
                }).toList(),
              ),
            ),
          );
  }

  Widget _buildTeam(TeamModel team) {
    return ListView(
      children: <Widget>[
        //build batsmen
        _buildTeamPlayers(
          team.batsmen,
          'Batsman',
        ),
        //build bowlers
        _buildTeamPlayers(
          team.bowlers,
          'Bowler',
        ),
        //build all rounders
        _buildTeamPlayers(
          team.allRounders,
          'All Rounder',
        ),
        //build wicket keepers
        _buildTeamPlayers(
          team.wicketKeepers,
          'Wicket Keeper',
        ),
      ],
    );
  }

  Widget _buildTeamPlayers(List<PlayerInfoModel> players, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: Text(
            '$title(${players.length})',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...players.map((player) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: Text(
              '${player.name}',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
