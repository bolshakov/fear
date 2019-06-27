## x.x.x

* Change `#get_or_else` and `#or_else` signatures, so it doesn't accept argument anymore (only block variant allowed)
* Remove `Try#or_else` and `Either#or_else` methods. Their signatures too complex for practical usage.

## 1.1.0 

* Add `Fear::Await.ready` and `Fear::Await.result`.
* Add callback versions with pattern matching `Fear::Future#on_success_match`, `#on_failure_match` and `#on_complete_match`.
* Implement immutable `Fear::Struct` 

## 1.0.0

* Rename `Fear::Done` to `Fear::Unit` ([@bolshakov][])
* Don't treat symbols as procs while pattern matching. See [#46](https://github.com/bolshakov/fear/pull/46) for motivation ([@bolshakov][])
* Revert commit removing `Fear::Future`. Now you can use `Fear.future` again ([@bolshakov][])
* Signatures of `Try#recover` and `Try#recover_with` changed. No it pattern match against container
  see https://github.com/bolshakov/fear/issues/41 for details . ([@bolshakov][])
* Add `#xcase` method to extract patterns ([@bolshakov][])
* Add `Fear.option`, `Fear.some`, `Fear.none`, `Fear.try`, `Fear.left`, `Fear.right`, and `Fear.for` alternatives to
  including mixins. ([@bolshakov][])

## 0.11.0

* Implement pattern matching and partial functions. See [README](https://github.com/bolshakov/fear#pattern-matching-api-documentation) ([@bolshakov][])
* `#to_a` method removed ([@bolshakov][])
* `For` syntax changed. See [diff](https://github.com/bolshakov/fear/pull/22/files#diff-04c6e90faac2675aa89e2176d2eec7d8) ([@bolshakov][])
* `Fear::None` is singleton object now and could not be instantiated ([@bolshakov][])

  You have to change all `Fear::None.new` invocations to `Fear::None`.

## 0.10.0

* Test against last supported ruby versions: 2.4.5, 2.5.3, 2.6.1 ([@bolshakov][])
* You can use `fear` with any `dry-equalizer` version (up to 0.2.1) ([@bolshakov][])

## 0.9.0

* Test against last supported ruby versions: 2.3.7, 2.4.4, 2.5.1 ([@bolshakov][])
* Make possible to pass to `#get_or_else` nil and false values ([@bolshakov][])

## 0.8.0

* Add `Fear::Done` to represent successful completion without a value. ([@bolshakov][])

## 0.7.0

* Better errors for types assertions ([@bolshakov][])

## 0.6.0

* Added `Either#or_else` and `Option#or_else`. `Try#or_else` may accept only block ([@bolshakov][])
  
[@bolshakov]: https://github.com/bolshakov
