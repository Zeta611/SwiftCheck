//
//  GenSpec.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 5/27/15.
//  Copyright (c) 2015 TypeLift. All rights reserved.
//

import XCTest
import SwiftCheck

class GenSpec : XCTestCase {
	func testAll() {
		property["frequency 1"] = {
			let g = Gen.frequency([
				(10, Gen.pure(0)),
				(5, Gen.pure(1)),
			])

			return forAll(g) { (i : Int) in
				return true
			}
		}()

		property["frequency 2"] = {
			let g = Gen.frequency([
				(10, Gen.pure(0)),
				(5, Gen.pure(1)),
			])

			return forAll(g) { (i : Int) in
				return true
			}
		}()

		property["frequency 3"] = forAll(Gen<Int>.choose((0, 1000))) { n in
			forAll(Gen.frequency(Array(count: n, repeatedValue: (1, Gen.pure(0))))) { $0 == 0 }
		}

		property["pure"] = {
			let g = Gen.pure(0)
			return forAll(g) { $0 == 0 }
		}()

		property["elements n"] = forAll { (xss : ArrayOf<Int>) in
			if xss.getArray.isEmpty {
				return Discard()
			}
			let l = Set(xss.getArray)
			return forAll(Gen.elements(xss.getArray)) { l.contains($0) }
		}

		property["elements 2"] = forAll { (n1 : Int, n2 : Int) in
			return forAll(Gen.elements([n1, n2])) { $0 == n1 || $0 == n2 }
		}

		property["oneOf n"] = forAll { (xss : ArrayOf<Int>) in
			if xss.getArray.isEmpty {
				return Discard()
			}
			let l = Set(xss.getArray)
			return forAll(Gen.oneOf(xss.getArray.map({ Gen.pure($0) }))) { l.contains($0) }
		}

		property["elements 2"] = forAll { (n1 : Int, n2 : Int) in
			let g1 = Gen.pure(n1)
			let g2 = Gen.pure(n2)
			return forAll(Gen.oneOf([g1, g2])) { $0 == n1 || $0 == n2 }
		}

		property["listOf n"] = forAll(Gen<Int>.choose((0, 100))) { n in
			let g = Int.arbitrary().vectorOf(n).fmap({ ArrayOf($0) })
			return forAll(g) { $0.getArray.count == n }
		}

		property["listOf 0"] = forAll(Int.arbitrary().vectorOf(0).fmap({ ArrayOf($0) })) {
			return $0.getArray.count == 0
		}

		property["suchThat"] = {
			let g = String.arbitrary().suchThat({ !$0.isEmpty }).suchThat({ $0.rangeOfString(",") == nil })
			return forAll(g) { str in
				return !(str.isEmpty || str.rangeOfString(",") != nil)
			}
		}()

		property["suchThat 1"] = {
			let g = String.arbitrary().suchThat({ !$0.isEmpty }).suchThat({ $0.rangeOfString(",") == nil })
			return forAll(g) { str in
				return !str.isEmpty
			}
		}()

		property["suchThat 2"] = {
			let g = String.arbitrary().suchThat({ !$0.isEmpty }).suchThat({ $0.rangeOfString(",") == nil })
			return forAll(g) { str in
				return str.rangeOfString(",") == nil
			}
		}()
	}
}
