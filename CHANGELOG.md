## 2.0.0 (not yet released)

* Added `Fear::Option#present?` and `Fear::Option#empty?` methods ([@Lokideos][])
* Start testing against Ruby 3.0.0 ([@bolshakov][]) 
* Minimal supported Ruby version is 2.6.0 ([@bolshakov][]) 
* Make future and promises compatible with Ruby 3.0 method syntax. ([@bolshakov][]) 
* Get rid off autoload in favor of require. Autoload appeared to be not thread-safe. ([@bolshakov][]) 
* All monads are shareable with Ractors ([@bolshakov][]) 
* Drop pattern extraction support (`Fear.xcase`). ([@bolshakov][]) 
* Add top-level factory methods: `Fear::Some`, `Fear::Option`, `Fear::Right`, `Fear::Left` ([@bolshakov][]) 
  `Fear::Try`, `Fear::Success`, and `Fear::Failure`. ([@bolshakov][]) 
   
## 1.2.0

* Implement `Fear::Option#zip` and `Fear::Future#zip` with block argument ([@bolshakov][]) 
* Drop ruby 2.4.x support, test against ruby 2.7.x ([@bolshakov][])
* Implement `Fear::Option#filter_map`  ([@bolshakov][])
* Add dry-types extentions to wrap nullable values. ([@bolshakov][])
* Implement pattern matching for ruby >= 2.7
* Deprecate `Fear.xcase`

## 1.1.0 

* Add `Fear::Await.ready` and `Fear::Await.result`. ([@bolshakov][])
* Add callback versions with pattern matching `Fear::Future#on_success_match`, `#on_failure_match` and `#on_complete_match`. ([@bolshakov][])
* Implement immutable `Fear::Struct`. ([@bolshakov][])

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
[@Lokideos]: https://github.com/Lokideos
