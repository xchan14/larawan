/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2023 Your Name <chancamilon@proton.me>
 */
using Gtk;
namespace Larawan.Widgets {

  public class Slider : Scale {

    public double value {
      get{ return get_value(); }
    }

    public Slider(Orientation orientation, Adjustment adjustment) {
      this.orientation = orientation;
      this.adjustment = adjustment;
    }

  }


}