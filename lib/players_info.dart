import 'dart:io';

import 'package:dream11_predictor/generate_teams.dart';
import 'package:dream11_predictor/teams_filter.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

enum PlayerType {
  batsman,
  bowler,
  allRounder,
  wicketKeeper,
}

class PlayerInfoModel {
  final String name;
  final double credits;
  final double selectedByInPercentage;
  final PlayerType type;
  final String team;

  PlayerInfoModel({
    required this.name,
    required this.credits,
    required this.selectedByInPercentage,
    required this.type,
    required this.team,
  });
}

class PlayersFilterModel {
  ///[7,4] means 7 players in team A & 4 players in Team B
  ///Possible combinations as per the rules are [[7,4],[6,5],[5,6],[4,7]]
  final List<List<int>> teamCombinations;
  final RangeValues wicketKeepersRange;
  final RangeValues allRoundersRange;
  final RangeValues batsmenRange;
  final RangeValues bowlersRange;
  final List<PlayerInfoModel> excludedPlayers;

  PlayersFilterModel({
    required this.teamCombinations,
    required this.wicketKeepersRange,
    required this.allRoundersRange,
    required this.batsmenRange,
    required this.bowlersRange,
    required this.excludedPlayers,
  });
}

class PlayersInfo extends StatefulWidget {
  const PlayersInfo({
    Key? key,
  }) : super(key: key);

  @override
  State<PlayersInfo> createState() => _PlayersInfoState();
}

class _PlayersInfoState extends State<PlayersInfo> {
  List<PlayerInfoModel> _players = [];
  TeamModel? _teamA;
  TeamModel? _teamB;
  final PlayersFilterModel _defaultFilters = PlayersFilterModel(
    teamCombinations: [
      [7, 4],
      [6, 5],
      [5, 6],
      [4, 7]
    ],
    allRoundersRange: const RangeValues(1, 4),
    batsmenRange: const RangeValues(3, 5),
    bowlersRange: const RangeValues(3, 5),
    wicketKeepersRange: const RangeValues(1, 3),
    excludedPlayers: [],
  );

  Future<void> _readExcelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null) {
      _players = [];
      File file = File(result.files.single.path!);

      var bytes = file.readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      for (var table in excel.tables.keys) {
        bool isFirstRow = true;
        for (List<Data?> row in excel.tables[table]!.rows) {
          // Skip the first row as it is the header
          if (!isFirstRow) {
            try {
              PlayerType? type;

              switch (row[3]!.value.toString().trim()) {
                case 'batsman':
                  type = PlayerType.batsman;
                  break;
                case 'bowler':
                  type = PlayerType.bowler;
                  break;
                case 'allRounder':
                  type = PlayerType.allRounder;
                  break;
                case 'wicketKeeper':
                  type = PlayerType.wicketKeeper;
                  break;
              }

              _players.add(
                PlayerInfoModel(
                  name: row[0]?.value,
                  credits: double.parse(row[1]?.value.toString() ?? '0.0'),
                  selectedByInPercentage:
                      double.parse(row[2]?.value.toString() ?? '0.0'),
                  type: type!,
                  team: row[4]?.value,
                ),
              );
            } catch (e) {
              print(e);
            }
          } else {
            isFirstRow = false;
          }
        }
      }

      String? teamAName;
      String? teamBName;

      for (var i = 0; i < _players.length; i++) {
        if (i == 0) {
          teamAName = _players[i].team;
        } else if (teamAName != _players[i].team) {
          teamBName = _players[i].team;
        }

        if (teamAName != null && teamBName != null) {
          break;
        }
      }

      List<PlayerInfoModel> teamAPlayers =
          _players.where((element) => element.team == teamAName).toList();

      List<PlayerInfoModel> teamBPlayers =
          _players.where((element) => element.team == teamBName).toList();

      _teamA = TeamModel(
        name: teamAName!,
        batsmen: teamAPlayers
            .where((element) => element.type == PlayerType.batsman)
            .toList(),
        bowlers: teamAPlayers
            .where((element) => element.type == PlayerType.bowler)
            .toList(),
        allRounders: teamAPlayers
            .where((element) => element.type == PlayerType.allRounder)
            .toList(),
        wicketKeepers: teamAPlayers
            .where((element) => element.type == PlayerType.wicketKeeper)
            .toList(),
      );

      _teamB = TeamModel(
        name: teamBName!,
        batsmen: teamBPlayers
            .where((element) => element.type == PlayerType.batsman)
            .toList(),
        bowlers: teamBPlayers
            .where((element) => element.type == PlayerType.bowler)
            .toList(),
        allRounders: teamBPlayers
            .where((element) => element.type == PlayerType.allRounder)
            .toList(),
        wicketKeepers: teamBPlayers
            .where((element) => element.type == PlayerType.wicketKeeper)
            .toList(),
      );

      setState(() {});
    } else {
      // User canceled the picker
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Players Info'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _players.clear();
              setState(() {});
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_players.isEmpty)
              MaterialButton(
                child: const Text('Upload Excel File'),
                color: Theme.of(context).primaryColor,
                textTheme: ButtonTextTheme.primary,
                onPressed: _readExcelFile,
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: _players.length,
                  itemBuilder: (context, index) {
                    final playerInfo = _players[index];
                    return ListTile(
                      title: Text("${index + 1}. ${playerInfo.name}"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Credits: ${playerInfo.credits}'),
                          Text(
                            'Selected By: ${playerInfo.selectedByInPercentage}%',
                          ),
                          Text('Type: ${playerInfo.type}'),
                          Text('Team: ${playerInfo.team}'),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: _players.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () async {
                PlayersFilterModel? filters = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TeamsFilter(
                      teamA: _teamA!,
                      teamB: _teamB!,
                      previousFilters: _defaultFilters,
                    ),
                  ),
                );

                if (filters != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GenerateTeams(
                        players: _players,
                        filters: filters,
                        teamA: _teamA!,
                        teamB: _teamB!,
                      ),
                    ),
                  );
                }
              },
              label: const Text(
                'Generate Teams',
              ),
              icon: const Icon(
                Icons.people,
              ),
            ),
    );
  }
}
