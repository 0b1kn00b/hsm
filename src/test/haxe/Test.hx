using stx.UnitTest;

import stx.UnitTest;

import stx.Log.*;

using stx.ds.Zipper;
using stx.Option;
using stx.Prelude;
using stx.Arrays;
using stx.Tuples;
using stx.Functions;
using stx.Compose;
using stx.Arrow;

import stx.Prelude;

import kwv.Locator;
using Hsm;

class Test{
	static function main(){
		Stax.init();
		var runner = UnitTest.rig();

		var tests : Array<TestCase> =
		[
			new hsm.HsmClassTest(),
			/*
				new hsm.HsmTest(),
			*/
		];

		runner.append(tests).run();
		
	}
}