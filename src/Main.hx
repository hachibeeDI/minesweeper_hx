package ;

import js.Browser;

import Enumerator;

import createjs.easeljs.Shape;
import createjs.easeljs.MouseEvent;
import createjs.easeljs.ColorFilter; // Colorfilter is not contained minified version
import createjs.easeljs.Stage;
import createjs.easeljs.Text;
import createjs.easeljs.Ticker;


using Enumerator;
using Lambda;


class Main
{
    public static inline var def_num_row: Int = 20;
    public static inline var def_num_col: Int = 20;

    public static function main()
    {
        Browser.window.onload = init_window_handler;
    }

    static function init_window_handler(_)
    {

        var canvas: js.html.CanvasElement = cast Browser.document.getElementById("canvas");
        initialize_canvas(canvas);

        var stage = new Stage(canvas);
        Ticker.useRAF = true;
        Ticker.setFPS(30);
        Ticker.addListener(function(){stage.update();});
        var field = new Field(def_num_row, def_num_col, stage);
    }

    static function initialize_canvas(canvas: js.html.CanvasElement): Void
    {
        canvas.width = def_num_row * Field.size_of_cells + def_num_row;
        canvas.height = def_num_col * Field.size_of_cells + def_num_col;
    }
}


class Field
{
    public static inline var size_of_cells: Int = 40;
    public var cells(default, null): Array<Cell>;
    public var stage(default, null): Stage;

    public function new(x: Int, y: Int, stage: Stage)
    {
        this.stage = stage;
        this.cells = this.initialize_cells(x, y);
        stage.update();
    }

    function initialize_cells(x, y): Array<Cell>
    {
        var cells = new Array<Cell>();
        for (row in 0...x) {
            for (col in 0...y) {
                cells.push(new Cell(this, row, col, (Std.random(5) < 1))); // 最大数とか考慮するのは後で
            }
        }
        return cells;
    }
}


class Cell
{
    private var field(default, null): Field;
    public var myshape(default, null): Shape;

    public var row(default, null): Int;
    public var column(default, null): Int;
    public var bomb(default, null): Bool;
    public var opened(default, default): Bool;

    public function new(field: Field, row, column, bomb)
    {
        this.field = field;
        this.row = row;
        this.column = column;
        this.bomb = bomb;
        this.opened = false;

        this.myshape = this.initialize_shape(field);
    }

    private function initialize_shape(field: Field): Shape
    {
        var myshape = new Shape();
        var cell_scale = Field.size_of_cells;
        myshape.graphics
            .beginFill("#FF0000")
            .drawRect(this.row, this.column, cell_scale, cell_scale)
            .endFill()
            ;
        myshape.x = this.row * cell_scale; myshape.y = this.column * cell_scale;
        myshape.onClick = function(e: MouseEvent) {
            if (this.bomb)
            {
                this.put_picture('B!');
                Utils.release_bomb_event(this);
                return;
            }

            var neighbors = this.get_neighbors();
            var cell_status = CellStatuses.get_status(neighbors.has_bomb.length);
            if (cell_status.equals(CellStatus.Zero(0)))
            {
                this.put_picture('0');
                neighbors.no_bomb.iter(function(c) {c.open();});
            }
            else
            {
                this.put_picture(
                    switch (cell_status) {
                        case One(v): Std.string(v);
                        case Two(v): Std.string(v);
                        case Three(v): Std.string(v);
                        case Four(v): Std.string(v);
                        case Five(v): Std.string(v);
                        case Six(v): Std.string(v);
                        case Seven(v): Std.string(v);
                        case Eight(v): Std.string(v);
                        case _: "b";
                    });
            }
            Utils.release_bomb_event(this);
        }
        field.stage.addChild(myshape);
        return myshape;
    }

    private function get_neighbors(): {has_bomb: Array<Cell>, no_bomb: Array<Cell>}
    {
        var this_row_i = this.row;
        var this_col_i = this.column;
        var targ_cells = this.field.cells;
        var with_bomb = new Array<Cell>();
        var no_bomb = new Array<Cell>();

        var neighbors = Utils.neibors_cells(this_row_i, this_col_i);
        // ここでキャッシュしないとIteratorは消費されてしまうくさい
        var col_indexes = neighbors.col_indexes.as_enumerable().list();
        neighbors.row_indexes.as_enumerable().iter(
                function(row_i) {
                    var targ_rows = targ_cells.filter(function(c) {return c.row == row_i;});
                    for (col_i in col_indexes) {
                        // ignore cell selfs
                        if (this_row_i == row_i && this_col_i == col_i) { continue; }

                        var targ = targ_rows.filter(function(c) {return c.column == col_i;}).pop();
                        if (targ.bomb) { with_bomb.push(targ); }
                        else { no_bomb.push(targ); }
                    }
                });
        return {has_bomb: with_bomb, no_bomb: no_bomb};
    }

    private function put_picture(text)
    {
        var tex = new Text(text, '12px Monaco', '#ffffff');
        tex.x = this.myshape.x + Field.size_of_cells * 0.5;
        tex.y = this.myshape.y + Field.size_of_cells * 0.5;
        this.field.stage.addChild(tex);
    }

    private function put_no_bomb()
    {
        this.put_picture('0');
    }

    /**
      * ボムが0のセルから連鎖的にあける時に使われる感じのメソッド
      * いい名前思いつかなかった
     */
    private function open()
    {
        if (this.bomb) return;

        var neighbors = this.get_neighbors();
        if (neighbors.has_bomb.empty())
        {
            this.put_no_bomb();
            Utils.release_bomb_event(this);
            neighbors.no_bomb
                .filter(function(c) {return c.opened == false;})
                .iter(
                    function(c) {
                        c.open();
                    }
                );
        }
    }
}


class Utils
{
    /**
      * @param row_index : 対象セルの行
      * @param col_index : 対象セルの列
      * @description : 対象セルの周囲のセルを算出するためのいい感じのアレを出してくれる。隅っことかも考慮してある。
     */
    public static function neibors_cells(row_index, col_index): {row_indexes: Iterator<Int>, col_indexes: Iterator<Int>}
    {
        var lower_row_bound = Std.int(Math.max(row_index - 1, 0));
        var upper_row_bound = Std.int(Math.min(row_index + 1, Main.def_num_row - 1));
        var lower_column_bound = Std.int(Math.max(col_index - 1, 0));
        var upper_column_bound = Std.int(Math.min(col_index + 1, Main.def_num_col - 1));
        return {
            row_indexes: (lower_row_bound...(upper_row_bound + 1))
            , col_indexes: (lower_column_bound...(upper_column_bound + 1))
        }
    }

    public static function release_bomb_event(cell: Cell)
    {
        cell.opened = true;
        cell.myshape.onClick = function(_) {return;};
    }
}


enum CellStatus
{
    Zero(i: Int);
    One(i: Int);
    Two(i: Int);
    Three(i: Int);
    Four(i: Int);
    Five(i: Int);
    Six(i: Int);
    Seven(i: Int);
    Eight(i: Int);
}


class CellStatuses
{
    public static function get_status(num_of_bombs: Int): CellStatus
    {
        return switch (num_of_bombs) {
            case 0: Zero(0);
            case 1: One(1);
            case 2: Two(2);
            case 3: Three(3);
            case 4: Four(4);
            case 5: Five(5);
            case 6: Six(6);
            case 7: Seven(7);
            case 8: Eight(8);
            case _: throw 'error';
        }
    }
}

