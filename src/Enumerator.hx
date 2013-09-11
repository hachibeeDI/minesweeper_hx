package ;

using Lambda;
using Enumerator;

class Enumerator
{
    /*
       convert Iterator<T> to Iterable<T>. Because Lambda is not support Iterator<T>.
    */
    public static function as_enumerable<T>(iter : Iterator<T>) : Iterable<T>
    {
        return {iterator : function(){return iter;}};
    }

    /*
       Make combination from two Listes.
    */
    public static function product<T>(xs : Iterable<T>, ys : Iterable<T>)
    {
        var zs: Array<Array<T>> = [];
        for( x in xs ){
            for( y in ys ){
                zs.push([x, y]);
            }
        }
        return zs;
    }

    /*
       flatmap
    */
    public static function flatmap<T>(xs : Iterable<Iterable<T>>, func : Iterable<T> -> Iterable<T>)
    {
        return xs.fold(function(xs1, xs2) {return func(xs1).concat(func(xs2));}, Lambda.list([]));
    }
}
