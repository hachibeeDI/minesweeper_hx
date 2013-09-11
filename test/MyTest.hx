
using Enumerator;
using Lambda;

class MyTest {

    static function main() {
        var r = new haxe.unit.TestRunner();
        r.add(new TestEnumerable());
        // your can add others TestCase here

        // finally, run the tests
        r.run();
    }

}


class TestEnumerable extends haxe.unit.TestCase
{
    public function test_product()
    {
        var ten_ten = [1, 2, 3].product([1, 2, 3]);
        this.assertEquals(
                ten_ten
                , [[1, 1], [1, 2], [1, 3], [2, 1], [2, 2], [2, 3], [3, 1], [3, 2], [3, 3]]
            );
        assertEquals('a', 'a');
    }
}
