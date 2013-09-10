package ;

import js.Browser;

import Enumerator;

import createjs.easeljs.Shape;
import createjs.easeljs.MouseEvent;
import createjs.easeljs.ColorFilter; // Colorfilter is not contained minified version
import createjs.easeljs.Stage;
import createjs.easeljs.Ticker;


using Enumerator;
using Lambda;


class Main
{
    public static inline var def_num_row: Int = 10;
    public static inline var def_num_col: Int = 10;

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
        Ticker.setFPS(60);
        Ticker.addListener(function(){stage.update();});
        var field = new Field(def_num_row, def_num_col, stage);
    }

    static function initialize_canvas(canvas: js.html.CanvasElement): Void
    {
        canvas.width = def_num_row * Field.size_of_cells;
        canvas.height = def_num_col * Field.size_of_cells;
    }

}


class Field
{
    public static inline var size_of_cells: Int = 50;
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
                cells.push(new Cell(this, row, col, (Std.random(2) < 0.5))); // 最大数とか考慮するのは後で
            }
        }
        return cells;
    }

}


class Cell
{
    private var myshape(default, null): Shape;
    private var field(default, null): Field;

    public var row(default, null): Int;
    public var column(default, null): Int;
    public var bomb(default, null): Bool;

    public function new(field: Field, row, column, bomb)
    {
        this.field = field;
        this.row = row;
        this.column = column;
        this.bomb = bomb;

        this.myshape = this.initialize_shape(field);
    }

    private function initialize_shape(field: Field): Shape
    {
        var myshape = new Shape();
        var cell_scale = Field.size_of_cells;
        myshape.graphics
            .beginFill("#FF0000")
            .drawRect(this.row * cell_scale, this.column * cell_scale, cell_scale - 1, cell_scale - 1)
            .endFill()
            ;
        myshape.onClick = function(e: MouseEvent) {
            if (this.bomb)
            {
                trace("cabooom!");
                return;
            }
            // こ↑こ↓
            var neighbors = this.get_neighbors();
            var cell_status = CellStatuses.get_status(neighbors.has_bomb.length);
            trace('${neighbors.has_bomb.length} bomb');
            if (cell_status.equals(CellStatus.Zero(0)))
            {
                // TODO: 連鎖部分は後で
            }
            else
            {
                var bi = switch (cell_status) {
                    case One(v): v / 10;
                    case Two(v): v / 10;
                    case Three(v): v / 10;
                    case Four(v): v / 10;
                    case Five(v): v / 10;
                    case Six(v): v / 10;
                    case Seven(v): v / 10;
                    case Eight(v): v / 10;
                    case _: 1;
                }
                var matrix = new ColorFilter(bi, bi, bi, 1);
                var s = this.myshape;
                s.filters = [matrix];
                s.cache(s.x, s.y, Field.size_of_cells - 1, Field.size_of_cells - 1);
            }
            trace(e.stageX);
        }
        field.stage.addChild(myshape);
        return myshape;
    }

    private function get_neighbors(): {has_bomb: Array<Cell>, no_bomb: Array<Cell>}
    {
        var with_bomb = new Array<Cell>();
        var no_bomb = new Array<Cell>();

        var neighbors = Utils.neibors_cells(this.row, this.column);
        var targ_cells = this.field.cells;
        for (row_i in neighbors.row_indexes) {
            var targ_rows = targ_cells.filter(function(c) {return c.row == row_i;});
            for (col_i in neighbors.col_indexes) {
                var targ = targ_rows.filter(function(c) {return c.column == col_i;}).pop();
                if (targ.bomb) with_bomb.push(targ);
                else no_bomb.push(targ);
            }
        }
        return {has_bomb: with_bomb, no_bomb: no_bomb};
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
            row_indexes: lower_row_bound...upper_row_bound + 1
            , col_indexes: lower_column_bound...upper_column_bound + 1
        }
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
            case 1: One(0);
            case 2: Two(10);
            case 3: Three(40);
            case 4: Four(70);
            case 5: Five(100);
            case 6: Six(130);
            case 7: Seven(160);
            case 8: Eight(180);
            case _: throw 'error';
        }
    }
}

/* 
enum Seed
{
    Alive(v: Cell);
    Dead(v: Cell);
}


class GameOfLife
{
    static public inline var cellSize : Int = 7;
    static public inline var numberOfRows : Int = 80;
    static public inline var numberOfColumns : Int = 80;
    static public inline var seedProbability : Float = 0.5;
    static public inline var tickLength : Int = 100;

    public var generation(default, null) : Generation;

    public function new(canvas : CanvasElement) {
        this.generation = new Generation(canvas, GameOfLife.tickLength);
    }

    public function start()
    {
        this.generation.next();
        haxe.Timer.delay(this.start, GameOfLife.tickLength);
    }

}

class Generation
{
    public var canvas(default, null) : CanvasElement;
    public var drawing_context(default, null) : CanvasRenderingContext2D;
    public var tick_length(default, null) : Int;
    public var current_cell_generation(default, null) : Array<Array<Seed>>;

    public function new(canvas : CanvasElement, tick_length : Int){
        this._initialize_canvas(canvas);
        this.drawing_context = canvas.getContext2d();
        this.tick_length = tick_length;
        this.current_cell_generation = this.seed();

        this.draw_grid();
    }

    function _initialize_canvas(canvas : CanvasElement) : Void
    {
        this.canvas = canvas;
        canvas.width = GameOfLife.cellSize * GameOfLife.numberOfColumns;
        canvas.height = GameOfLife.cellSize * GameOfLife.numberOfRows;
    }


    function seed() : Array<Array<Seed>>
    {
        var _current_cell_generation : Array<Array<Seed>> = [];
        for (row_index in 0...GameOfLife.numberOfRows)
        {
            var new_row : Array<Seed> = [];
            for (column_index in 0...GameOfLife.numberOfColumns)
            {
                var cell = {row: row_index, column: column_index};
                new_row.push(if (Std.random(2) < GameOfLife.seedProbability) Alive(cell) else Dead(cell));
            }
            _current_cell_generation.push(new_row);
        }
        return _current_cell_generation;
    }

    function draw_grid() : Void
    {
        for (row in 0...GameOfLife.numberOfRows)
        {
            for (column in 0...GameOfLife.numberOfColumns)
            {
                this.draw_cell(this.current_cell_generation[row][column]);
            }
        }

    }

    function draw_cell(cell : Seed) : Void
    {
        var _cell = (switch(cell) {case Alive(s) : s; case Dead(s) : s;});
        var x = _cell.row * GameOfLife.cellSize;
        var y = _cell.column * GameOfLife.cellSize;
        var fillStyle = switch(cell){
            case Alive(cell): "rgb(242, 198, 65)";
            case Dead(cell): "rgb(38, 38, 38)";
        }
        this.drawing_context.strokeStyle = 'rgba(242, 198, 65, 0.1)';
        this.drawing_context.strokeRect(x, y, GameOfLife.cellSize, GameOfLife.cellSize);

        this.drawing_context.fillStyle = fillStyle;
        this.drawing_context.fillRect(x, y, GameOfLife.cellSize, GameOfLife.cellSize);
    }

    function evolve_cell_generation() : Void
    {
        var new_cell_generation = [];

        for (row in 0...GameOfLife.numberOfRows) {
            var next_generation : Array<Seed> = [];
            for(column in 0...GameOfLife.numberOfColumns) {
                var evolved_cell : Seed = this.evolve_cell(this.current_cell_generation[row][column]);
                next_generation.push(evolved_cell);
            }
            new_cell_generation.push(next_generation);
        }
        this.current_cell_generation = new_cell_generation;
    }

    function evolve_cell(previous_cell : Seed) : Seed
    {

        var cell = switch(previous_cell){case Alive(c) : c; case Dead(c) : c;};
        var number_of_alive_neighbors = this.count_alive_neighbors(cell);
        return switch [previous_cell, number_of_alive_neighbors] {
            case [_, 3] : Alive(cell);
            case [Alive(c), 2] : Alive(c);
            case [_, _] : Dead(cell);
        }
    }

    public function count_alive_neighbors(cell : Cell) : Int
    {
        var current_generation = this.current_cell_generation;
        var lower_row_bound = Std.int(Math.max(cell.row - 1, 0));
        var upper_row_bound = Std.int(Math.min(cell.row + 1, GameOfLife.numberOfRows - 1));
        var lower_column_bound = Std.int(Math.max(cell.column - 1, 0));
        var upper_column_bound = Std.int(Math.min(cell.column + 1, GameOfLife.numberOfColumns - 1));

        var number_of_alive_neighbors =
        (lower_row_bound...upper_row_bound + 1).as_enumerable()
            .map(function(row_index)
                    {
                        return (lower_column_bound...upper_column_bound + 1).as_enumerable()
                                .filter(function(i) {return !(cell.row == row_index && cell.column == i);})
                                .map(function(column_index)
                                    {
                                        return switch(current_generation[row_index][column_index]) {
                                            case Alive(c): true;
                                            case _ : false;
                                        }
                                    }
                                );
                    }
                )
            .flatmap(function(xs){return xs;})
            .count(function(b){return b;});
        return number_of_alive_neighbors;
    }

    public function next() : Void
    {
        this.draw_grid();
        this.evolve_cell_generation();
    }

}
 */
