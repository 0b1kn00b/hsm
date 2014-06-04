
import utest.Runner;
import utest.ui.Report;

using stx.Options;
using stx.Arrays;
using stx.Tuples;
using stx.Functions;
using stx.Compose;

using Hsm;

class Test{
	static function main(){
		trace('entry point');
		var runner = new Runner();
		var rpr = Report.create(runner);
		
		var tests : Array<Dynamic> =
		[
			new hsm.HsmTest(),
			/*
				
			*/
		];
		tests.each(
			function(x){
				runner.addCase(x);
			}
		);
		
		runner.run();
	}
}