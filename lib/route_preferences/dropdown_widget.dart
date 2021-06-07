/*
 * Copyright (C) 2020-2021 HERE Europe B.V.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 * License-Filename: LICENSE
 */

import 'enum_string_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Dropdown list widget.
class DropdownWidget extends StatelessWidget {
  /// Creates a widget.
  DropdownWidget({
    Key key,
    @required this.data,
    @required this.selectedValue,
    @required this.onChanged,
  }) : super(key: key);

  /// Dropdown list items.
  final Map<int, String> data;
  /// Id of the selected value.
  final int selectedValue;
  /// Called when the selected item is changed.
  final Function onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      isExpanded: true,
      value: selectedValue ?? EnumStringHelper.noneValueIndex,
      items: data.entries
          .map(
            (entry) => DropdownMenuItem(
              child: ListTile(title: Text(entry.value)),
              value: entry.key,
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}
