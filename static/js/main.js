(function () { "use strict";
var $estr = function() { return js.Boot.__string_rec(this,''); };
var Enumerator = function() { }
Enumerator.__name__ = true;
Enumerator.as_enumerable = function(iter) {
	return { iterator : function() {
		return iter;
	}};
}
Enumerator.product = function(xs,ys) {
	var zs = [];
	var $it0 = $iterator(xs)();
	while( $it0.hasNext() ) {
		var x = $it0.next();
		var $it1 = $iterator(ys)();
		while( $it1.hasNext() ) {
			var y = $it1.next();
			zs.push([x,y]);
		}
	}
	return zs;
}
Enumerator.flatmap = function(xs,func) {
	return Lambda.fold(xs,function(xs1,xs2) {
		return Lambda.concat(func(xs1),func(xs2));
	},Lambda.list([]));
}
var HxOverrides = function() { }
HxOverrides.__name__ = true;
HxOverrides.iter = function(a) {
	return { cur : 0, arr : a, hasNext : function() {
		return this.cur < this.arr.length;
	}, next : function() {
		return this.arr[this.cur++];
	}};
}
var IntIterator = function(min,max) {
	this.min = min;
	this.max = max;
};
IntIterator.__name__ = true;
IntIterator.prototype = {
	next: function() {
		return this.min++;
	}
	,hasNext: function() {
		return this.min < this.max;
	}
}
var Lambda = function() { }
Lambda.__name__ = true;
Lambda.list = function(it) {
	var l = new List();
	var $it0 = $iterator(it)();
	while( $it0.hasNext() ) {
		var i = $it0.next();
		l.add(i);
	}
	return l;
}
Lambda.iter = function(it,f) {
	var $it0 = $iterator(it)();
	while( $it0.hasNext() ) {
		var x = $it0.next();
		f(x);
	}
}
Lambda.fold = function(it,f,first) {
	var $it0 = $iterator(it)();
	while( $it0.hasNext() ) {
		var x = $it0.next();
		first = f(x,first);
	}
	return first;
}
Lambda.concat = function(a,b) {
	var l = new List();
	var $it0 = $iterator(a)();
	while( $it0.hasNext() ) {
		var x = $it0.next();
		l.add(x);
	}
	var $it1 = $iterator(b)();
	while( $it1.hasNext() ) {
		var x = $it1.next();
		l.add(x);
	}
	return l;
}
var List = function() {
	this.length = 0;
};
List.__name__ = true;
List.prototype = {
	iterator: function() {
		return { h : this.h, hasNext : function() {
			return this.h != null;
		}, next : function() {
			if(this.h == null) return null;
			var x = this.h[0];
			this.h = this.h[1];
			return x;
		}};
	}
	,add: function(item) {
		var x = [item];
		if(this.h == null) this.h = x; else this.q[1] = x;
		this.q = x;
		this.length++;
	}
}
var Main = function() { }
Main.__name__ = true;
Main.main = function() {
	js.Browser.window.onload = Main.init_window_handler;
}
Main.init_window_handler = function(_) {
	var canvas = js.Browser.document.getElementById("canvas");
	Main.initialize_canvas(canvas);
	var stage = new createjs.Stage(canvas);
	createjs.Ticker.useRAF = true;
	createjs.Ticker.setFPS(60);
	createjs.Ticker.addListener(function() {
		stage.update();
	});
	var field = new Field(10,10,stage);
}
Main.initialize_canvas = function(canvas) {
	canvas.width = 500;
	canvas.height = 500;
}
var Field = function(x,y,stage) {
	this.stage = stage;
	this.cells = this.initialize_cells(x,y);
	stage.update();
};
Field.__name__ = true;
Field.prototype = {
	initialize_cells: function(x,y) {
		var cells = new Array();
		var _g = 0;
		while(_g < x) {
			var row = _g++;
			var _g1 = 0;
			while(_g1 < y) {
				var col = _g1++;
				cells.push(new Cell(this,row,col,Std.random(2) < 0.5));
			}
		}
		return cells;
	}
}
var Cell = function(field,row,column,bomb) {
	this.field = field;
	this.row = row;
	this.column = column;
	this.bomb = bomb;
	this.myshape = this.initialize_shape(field);
};
Cell.__name__ = true;
Cell.prototype = {
	get_neighbors: function() {
		var this_row_i = this.row;
		var this_col_i = this.column;
		var targ_cells = this.field.cells;
		var with_bomb = new Array();
		var no_bomb = new Array();
		var neighbors = Utils.neibors_cells(this_row_i,this_col_i);
		var col_indexes = Lambda.list(Enumerator.as_enumerable(neighbors.col_indexes));
		Lambda.iter(Enumerator.as_enumerable(neighbors.row_indexes),function(row_i) {
			var targ_rows = targ_cells.filter(function(c) {
				return c.row == row_i;
			});
			var $it0 = col_indexes.iterator();
			while( $it0.hasNext() ) {
				var col_i = $it0.next();
				var col_i1 = [col_i];
				if(this_row_i == row_i && this_col_i == col_i1[0]) continue;
				var targ = targ_rows.filter((function(col_i1) {
					return function(c) {
						return c.column == col_i1[0];
					};
				})(col_i1)).pop();
				console.log("" + row_i + ", " + col_i1[0] + " -> " + Std.string(targ.bomb));
				if(targ.bomb) with_bomb.push(targ); else no_bomb.push(targ);
			}
		});
		return { has_bomb : with_bomb, no_bomb : no_bomb};
	}
	,initialize_shape: function(field) {
		var _g = this;
		var myshape = new createjs.Shape();
		var cell_scale = 50;
		myshape.graphics.beginFill("#FF0000").drawRect(this.row * cell_scale,this.column * cell_scale,cell_scale - 1,cell_scale - 1).endFill();
		myshape.onClick = function(e) {
			if(_g.bomb) {
				var show_bomb = new createjs.Text("B!","11px Monaco","#ffffff");
				show_bomb.x = e.stageX;
				show_bomb.y = e.stageY;
				_g.field.stage.addChild(show_bomb);
				return;
			}
			var neighbors = _g.get_neighbors();
			var cell_status = CellStatuses.get_status(neighbors.has_bomb.length);
			console.log("" + neighbors.has_bomb.length + " bomb");
			if(Type.enumEq(cell_status,CellStatus.Zero(0))) {
			} else {
				var bi = new createjs.Text((function($this) {
					var $r;
					var $e = (cell_status);
					switch( $e[1] ) {
					case 1:
						var v = $e[2];
						$r = Std.string(v);
						break;
					case 2:
						var v = $e[2];
						$r = Std.string(v);
						break;
					case 3:
						var v = $e[2];
						$r = Std.string(v);
						break;
					case 4:
						var v = $e[2];
						$r = Std.string(v);
						break;
					case 5:
						var v = $e[2];
						$r = Std.string(v);
						break;
					case 6:
						var v = $e[2];
						$r = Std.string(v);
						break;
					case 7:
						var v = $e[2];
						$r = Std.string(v);
						break;
					case 8:
						var v = $e[2];
						$r = Std.string(v);
						break;
					default:
						$r = "b";
					}
					return $r;
				}(this)),"11px Monaco","#ffffff");
				bi.x = e.stageX;
				bi.y = e.stageY;
				_g.field.stage.addChild(bi);
			}
		};
		field.stage.addChild(myshape);
		return myshape;
	}
}
var Utils = function() { }
Utils.__name__ = true;
Utils.neibors_cells = function(row_index,col_index) {
	var lower_row_bound = Math.max(row_index - 1,0) | 0;
	var upper_row_bound = Math.min(row_index + 1,9) | 0;
	var lower_column_bound = Math.max(col_index - 1,0) | 0;
	var upper_column_bound = Math.min(col_index + 1,9) | 0;
	console.log("row lower: " + lower_row_bound);
	console.log("row upper: " + upper_row_bound);
	console.log("col lower: " + lower_column_bound);
	console.log("col upper: " + upper_column_bound);
	return { row_indexes : new IntIterator(lower_row_bound,upper_row_bound + 1), col_indexes : new IntIterator(lower_column_bound,upper_column_bound + 1)};
}
var CellStatus = { __ename__ : true, __constructs__ : ["Zero","One","Two","Three","Four","Five","Six","Seven","Eight"] }
CellStatus.Zero = function(i) { var $x = ["Zero",0,i]; $x.__enum__ = CellStatus; $x.toString = $estr; return $x; }
CellStatus.One = function(i) { var $x = ["One",1,i]; $x.__enum__ = CellStatus; $x.toString = $estr; return $x; }
CellStatus.Two = function(i) { var $x = ["Two",2,i]; $x.__enum__ = CellStatus; $x.toString = $estr; return $x; }
CellStatus.Three = function(i) { var $x = ["Three",3,i]; $x.__enum__ = CellStatus; $x.toString = $estr; return $x; }
CellStatus.Four = function(i) { var $x = ["Four",4,i]; $x.__enum__ = CellStatus; $x.toString = $estr; return $x; }
CellStatus.Five = function(i) { var $x = ["Five",5,i]; $x.__enum__ = CellStatus; $x.toString = $estr; return $x; }
CellStatus.Six = function(i) { var $x = ["Six",6,i]; $x.__enum__ = CellStatus; $x.toString = $estr; return $x; }
CellStatus.Seven = function(i) { var $x = ["Seven",7,i]; $x.__enum__ = CellStatus; $x.toString = $estr; return $x; }
CellStatus.Eight = function(i) { var $x = ["Eight",8,i]; $x.__enum__ = CellStatus; $x.toString = $estr; return $x; }
var CellStatuses = function() { }
CellStatuses.__name__ = true;
CellStatuses.get_status = function(num_of_bombs) {
	return (function($this) {
		var $r;
		switch(num_of_bombs) {
		case 0:
			$r = CellStatus.Zero(0);
			break;
		case 1:
			$r = CellStatus.One(1);
			break;
		case 2:
			$r = CellStatus.Two(2);
			break;
		case 3:
			$r = CellStatus.Three(3);
			break;
		case 4:
			$r = CellStatus.Four(4);
			break;
		case 5:
			$r = CellStatus.Five(5);
			break;
		case 6:
			$r = CellStatus.Six(6);
			break;
		case 7:
			$r = CellStatus.Seven(7);
			break;
		case 8:
			$r = CellStatus.Eight(8);
			break;
		default:
			$r = (function($this) {
				var $r;
				throw "error";
				return $r;
			}($this));
		}
		return $r;
	}(this));
}
var Std = function() { }
Std.__name__ = true;
Std.string = function(s) {
	return js.Boot.__string_rec(s,"");
}
Std.random = function(x) {
	return x <= 0?0:Math.floor(Math.random() * x);
}
var Type = function() { }
Type.__name__ = true;
Type.enumEq = function(a,b) {
	if(a == b) return true;
	try {
		if(a[0] != b[0]) return false;
		var _g1 = 2, _g = a.length;
		while(_g1 < _g) {
			var i = _g1++;
			if(!Type.enumEq(a[i],b[i])) return false;
		}
		var e = a.__enum__;
		if(e != b.__enum__ || e == null) return false;
	} catch( e ) {
		return false;
	}
	return true;
}
var js = {}
js.Boot = function() { }
js.Boot.__name__ = true;
js.Boot.__string_rec = function(o,s) {
	if(o == null) return "null";
	if(s.length >= 5) return "<...>";
	var t = typeof(o);
	if(t == "function" && (o.__name__ || o.__ename__)) t = "object";
	switch(t) {
	case "object":
		if(o instanceof Array) {
			if(o.__enum__) {
				if(o.length == 2) return o[0];
				var str = o[0] + "(";
				s += "\t";
				var _g1 = 2, _g = o.length;
				while(_g1 < _g) {
					var i = _g1++;
					if(i != 2) str += "," + js.Boot.__string_rec(o[i],s); else str += js.Boot.__string_rec(o[i],s);
				}
				return str + ")";
			}
			var l = o.length;
			var i;
			var str = "[";
			s += "\t";
			var _g = 0;
			while(_g < l) {
				var i1 = _g++;
				str += (i1 > 0?",":"") + js.Boot.__string_rec(o[i1],s);
			}
			str += "]";
			return str;
		}
		var tostr;
		try {
			tostr = o.toString;
		} catch( e ) {
			return "???";
		}
		if(tostr != null && tostr != Object.toString) {
			var s2 = o.toString();
			if(s2 != "[object Object]") return s2;
		}
		var k = null;
		var str = "{\n";
		s += "\t";
		var hasp = o.hasOwnProperty != null;
		for( var k in o ) { ;
		if(hasp && !o.hasOwnProperty(k)) {
			continue;
		}
		if(k == "prototype" || k == "__class__" || k == "__super__" || k == "__interfaces__" || k == "__properties__") {
			continue;
		}
		if(str.length != 2) str += ", \n";
		str += s + k + " : " + js.Boot.__string_rec(o[k],s);
		}
		s = s.substring(1);
		str += "\n" + s + "}";
		return str;
	case "function":
		return "<function>";
	case "string":
		return o;
	default:
		return String(o);
	}
}
js.Browser = function() { }
js.Browser.__name__ = true;
function $iterator(o) { if( o instanceof Array ) return function() { return HxOverrides.iter(o); }; return typeof(o.iterator) == 'function' ? $bind(o,o.iterator) : o.iterator; };
var $_, $fid = 0;
function $bind(o,m) { if( m == null ) return null; if( m.__id__ == null ) m.__id__ = $fid++; var f; if( o.hx__closures__ == null ) o.hx__closures__ = {}; else f = o.hx__closures__[m.__id__]; if( f == null ) { f = function(){ return f.method.apply(f.scope, arguments); }; f.scope = o; f.method = m; o.hx__closures__[m.__id__] = f; } return f; };
Math.__name__ = ["Math"];
Math.NaN = Number.NaN;
Math.NEGATIVE_INFINITY = Number.NEGATIVE_INFINITY;
Math.POSITIVE_INFINITY = Number.POSITIVE_INFINITY;
Math.isFinite = function(i) {
	return isFinite(i);
};
Math.isNaN = function(i) {
	return isNaN(i);
};
String.__name__ = true;
Array.__name__ = true;
Main.def_num_row = 10;
Main.def_num_col = 10;
Field.size_of_cells = 50;
js.Browser.window = typeof window != "undefined" ? window : null;
js.Browser.document = typeof window != "undefined" ? window.document : null;
Main.main();
})();

//@ sourceMappingURL=main.js.map