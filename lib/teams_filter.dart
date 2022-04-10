import 'package:dream11_predictor/common.dart';
import 'package:dream11_predictor/extensions.dart';
import 'package:dream11_predictor/generate_teams.dart';
import 'package:dream11_predictor/players_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class TeamsFilter extends StatefulWidget {
  final TeamModel teamA;
  final TeamModel teamB;
  final PlayersFilterModel previousFilters;

  const TeamsFilter({
    Key? key,
    required this.teamA,
    required this.teamB,
    required this.previousFilters,
  }) : super(key: key);

  @override
  State<TeamsFilter> createState() => _TeamsFilterState();
}

class _TeamsFilterState extends State<TeamsFilter> {
  final _formKey = GlobalKey<FormBuilderState>();

  late RangeValues _wicketKeepersRange =
      widget.previousFilters.wicketKeepersRange;
  late RangeValues _allRoundersRange = widget.previousFilters.allRoundersRange;
  late RangeValues _batsmenRange = widget.previousFilters.batsmenRange;
  late RangeValues _bowlersRange = widget.previousFilters.bowlersRange;
  final List<List<int>> _possibleTeamCombinations = [
    [7, 4],
    [6, 5],
    [5, 6],
    [4, 7],
  ];

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: context.primaryColor,
                    ),
                  ),
                  const Icon(Icons.close).onTap(() {
                    Navigator.pop(context);
                  })
                ],
              ),
              const Divider(),
              Expanded(
                child: FormBuilder(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: ListView(
                    children: [
                      8.height,
                      Container(
                        padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
                        width: context.width(),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black.withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(defaultRadius),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Team Combinations',
                              style: TextStyle(
                                fontSize: 16,
                                color: context.primaryColor,
                              ),
                            ),
                            8.height,
                            Row(
                              children: [
                                const Spacer(),
                                Expanded(
                                  child: Text(
                                    widget.teamA.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    widget.teamB.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            ..._possibleTeamCombinations.map((e) {
                              return FormBuilderCheckbox(
                                contentPadding: EdgeInsets.zero,
                                name: 'team_combination_${e[0]}_${e[1]}',
                                initialValue: widget
                                    .previousFilters.teamCombinations
                                    .where((element) =>
                                        element[0] == e[0] &&
                                        element[1] == e[1])
                                    .isNotEmpty,
                                title: Row(
                                  children: [
                                    const Spacer(),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        '${e[0]}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        '${e[1]}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                      16.height,
                      Container(
                        padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
                        width: context.width(),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black.withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(defaultRadius),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Players Range',
                              style: TextStyle(
                                fontSize: 16,
                                color: context.primaryColor,
                              ),
                            ),
                            8.height,
                            const Text(
                              'Wicket Keepers',
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            RangeSlider(
                              values: _wicketKeepersRange,
                              min: 1,
                              max: 4,
                              divisions: 3,
                              labels: RangeLabels(
                                _wicketKeepersRange.start.round().toString(),
                                _wicketKeepersRange.end.round().toString(),
                              ),
                              onChanged: (RangeValues values) {
                                setState(() {
                                  _wicketKeepersRange = values;
                                });
                              },
                            ),
                            8.height,
                            const Text(
                              'All Rounders',
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            RangeSlider(
                              values: _allRoundersRange,
                              min: 1,
                              max: 4,
                              divisions: 3,
                              labels: RangeLabels(
                                _allRoundersRange.start.round().toString(),
                                _allRoundersRange.end.round().toString(),
                              ),
                              onChanged: (RangeValues values) {
                                setState(() {
                                  _allRoundersRange = values;
                                });
                              },
                            ),
                            8.height,
                            const Text(
                              'Batsmen',
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            RangeSlider(
                              values: _batsmenRange,
                              min: 3,
                              max: 6,
                              divisions: 3,
                              labels: RangeLabels(
                                _batsmenRange.start.round().toString(),
                                _batsmenRange.end.round().toString(),
                              ),
                              onChanged: (RangeValues values) {
                                setState(() {
                                  _batsmenRange = values;
                                });
                              },
                            ),
                            8.height,
                            const Text(
                              'Bowlers',
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            RangeSlider(
                              values: _bowlersRange,
                              min: 3,
                              max: 6,
                              divisions: 3,
                              labels: RangeLabels(
                                _bowlersRange.start.round().toString(),
                                _bowlersRange.end.round().toString(),
                              ),
                              onChanged: (RangeValues values) {
                                setState(() {
                                  _bowlersRange = values;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      16.height,
                      Container(
                        padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
                        width: context.width(),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black.withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(defaultRadius),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Excluded Players',
                              style: TextStyle(
                                fontSize: 16,
                                color: context.primaryColor,
                              ),
                            ),
                            8.height,
                            _buildExcludedPlayers(widget.teamA, 'team_a'),
                            16.height,
                            _buildExcludedPlayers(widget.teamB, 'team_b'),
                          ],
                        ),
                      ),
                      100.height,
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: null,
          backgroundColor: context.primaryColor,
          child: const Icon(Icons.done, color: Colors.white),
          onPressed: () {
            _formKey.currentState!.saveAndValidate();
            var formData = _formKey.currentState!.value;

            List<PlayerInfoModel>? teamAExcludedWicketKeepers =
                formData['team_a_excluded_wicket_keepers'];
            List<PlayerInfoModel>? teamAExcludedBatsMen =
                formData['team_a_excluded_batsmen'];
            List<PlayerInfoModel>? teamAExcludedBowlers =
                formData['team_a_excluded_bowlers'];
            List<PlayerInfoModel>? teamAExcludedAllRounders =
                formData['team_a_excluded_all_rounders'];

            List<PlayerInfoModel>? teamBExcludedWicketKeepers =
                formData['team_b_excluded_wicket_keepers'];
            List<PlayerInfoModel>? teamBExcludedBatsMen =
                formData['team_b_excluded_batsmen'];
            List<PlayerInfoModel>? teamBExcludedBowlers =
                formData['team_b_excluded_bowlers'];
            List<PlayerInfoModel>? teamBExcludedAllRounders =
                formData['team_b_excluded_all_rounders'];

            List<PlayerInfoModel> excludedPlayers = [
              ...teamAExcludedWicketKeepers ?? [],
              ...teamAExcludedBatsMen ?? [],
              ...teamAExcludedBowlers ?? [],
              ...teamAExcludedAllRounders ?? [],
              ...teamBExcludedWicketKeepers ?? [],
              ...teamBExcludedBatsMen ?? [],
              ...teamBExcludedBowlers ?? [],
              ...teamBExcludedAllRounders ?? [],
            ];

            List<List<int>> teamCombinations = [];
            for (List<int> teamCombination in _possibleTeamCombinations) {
              if (formData['team_combination_' + teamCombination.join('_')]) {
                teamCombinations.add(teamCombination);
              }
            }

            print(
                'Excluded Players: ${excludedPlayers.map((e) => e.name).toList()}');

            print('Team Combinations: $teamCombinations');

            print(
                'Wicket Keepers: ${_wicketKeepersRange.start} - ${_wicketKeepersRange.end}');

            print('Batsmen: ${_batsmenRange.start} - ${_batsmenRange.end}');

            print('Bowlers: ${_bowlersRange.start} - ${_bowlersRange.end}');

            print(
                'All Rounders: ${_allRoundersRange.start} - ${_allRoundersRange.end}');

            PlayersFilterModel filter = PlayersFilterModel(
              teamCombinations: teamCombinations,
              wicketKeepersRange: _wicketKeepersRange,
              allRoundersRange: _allRoundersRange,
              batsmenRange: _batsmenRange,
              bowlersRange: _bowlersRange,
              excludedPlayers: excludedPlayers,
            );

            Navigator.of(context).pop(filter);
          },
        ),
      ),
    );
  }

  Widget _buildExcludedPlayers(TeamModel team, String formNamePrefix) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        8.height,
        Text(
          team.name,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
        8.height,
        if (team.wicketKeepers.isNotEmpty)
          FormBuilderCheckboxGroup(
            name: '${formNamePrefix}_excluded_wicket_keepers',
            initialValue: widget.previousFilters.excludedPlayers
                .where((e) =>
                    e.team == team.name && e.type == PlayerType.wicketKeeper)
                .toList(),
            decoration: const InputDecoration(
              labelText: 'Wicket Keepers',
            ),
            options: team.wicketKeepers
                .map(
                  (e) => FormBuilderFieldOption(
                    value: e,
                    child: Text('${e.name} (${e.selectedByInPercentage}%)'),
                  ),
                )
                .toList(),
          )
        else
          const Text(
            'No Wicket Keepers',
            style: TextStyle(fontSize: 16, color: Colors.red),
          ),
        8.height,
        if (team.batsmen.isNotEmpty)
          FormBuilderCheckboxGroup(
            name: '${formNamePrefix}_excluded_batsmen',
            initialValue: widget.previousFilters.excludedPlayers
                .where(
                    (e) => e.team == team.name && e.type == PlayerType.batsman)
                .toList(),
            decoration: const InputDecoration(
              labelText: 'Batsmen',
            ),
            options: team.batsmen
                .map(
                  (e) => FormBuilderFieldOption(
                    value: e,
                    child: Text('${e.name} (${e.selectedByInPercentage}%)'),
                  ),
                )
                .toList(),
          )
        else
          const Text(
            'No Batsmen',
            style: TextStyle(fontSize: 16, color: Colors.red),
          ),
        8.height,
        if (team.allRounders.isNotEmpty)
          FormBuilderCheckboxGroup(
            name: '${formNamePrefix}_excluded_all_rounders',
            initialValue: widget.previousFilters.excludedPlayers
                .where((e) =>
                    e.team == team.name && e.type == PlayerType.allRounder)
                .toList(),
            decoration: const InputDecoration(
              labelText: 'All Rounders',
            ),
            options: team.allRounders
                .map(
                  (e) => FormBuilderFieldOption(
                    value: e,
                    child: Text('${e.name} (${e.selectedByInPercentage}%)'),
                  ),
                )
                .toList(),
          )
        else
          const Text(
            'No All Rounders',
            style: TextStyle(fontSize: 16, color: Colors.red),
          ),
        8.height,
        if (team.bowlers.isNotEmpty)
          FormBuilderCheckboxGroup(
            name: '${formNamePrefix}_excluded_bowlers',
            initialValue: widget.previousFilters.excludedPlayers
                .where(
                    (e) => e.team == team.name && e.type == PlayerType.bowler)
                .toList(),
            decoration: const InputDecoration(
              labelText: 'Bowlers',
            ),
            options: team.bowlers
                .map(
                  (e) => FormBuilderFieldOption(
                    value: e,
                    child: Text('${e.name} (${e.selectedByInPercentage}%)'),
                  ),
                )
                .toList(),
          )
        else
          const Text(
            'No Bowlers',
            style: TextStyle(fontSize: 16, color: Colors.red),
          ),
      ],
    );
  }
}
