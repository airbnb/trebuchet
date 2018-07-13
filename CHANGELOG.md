## 0.10.1 (Jul 13, 2018)
 - add PerDenomination strategy

## 0.10.0 (Nov 17, 2017)
  - Cache Trebuchet#launch?

## 0.9.18 (Sep 18, 2017)
  - Do not expose internal format

## 0.9.17 (Aug 15, 2017)
  - adds CustomRequestAware strategy

## 0.9.16 (Aug 9, 2017)
  - Don't raise an error if expiration date has not been previously set

## 0.9.15 (Aug 9, 2017)
  - Return payload for expiration date accessor

## 0.9.14 (Aug 9, 2017)
  - Expose expiration date accessor

## 0.9.13 (Aug 8, 2017)
  - Fix a typo

## 0.9.12 (Aug 3, 2017)
  - Add setter for expiration date

## 0.9.11 (Nov 16, 2016)
  - minor change: reduce number of times backend is hit in the launch methods

## 0.9.10 (Nov 14, 2016)
  - fix logical operators for logged out visitors

## 0.9.9 (Sep 15, 2016)
  - minor change: keep raw option hash in logic strategies for editing purpose

## 0.9.8 (July 27, 2016)
  - convert deserialized strategy names to symbols

## 0.9.7 (July 20, 2016)
  - logic operation strategies, e.g. AND, OR, and NOT

## 0.9.6 (April 5, 2016)
  - add :add_comment method to the Feature class

## 0.9.2 (October 11, 2015)
  - add :nobody and :everybody strategies
  - cache features
  - make :default strategy a singleton

## 0.9.1 (Jul 22, 2015)
  - fix last_update type in redis_hammerspaced

## 0.9.0 (Jul 22, 2015)
  - adds update_hammerspace method so we can sync redis into local hammerspace

## 0.8.1 (Jul 21, 2015)
  - update redis backend to update a sentinel to indicate modifications

## 0.8.0 (Jul 20, 2015)
  - adds a new backened redis_hammerspaced

## 0.6.3 (Sep 7, 2013)
  - reimplements the percent strategy
  - adds per-feature stubbing interface

## 0.0.4 (Dec 6, 2011)
  - add experiment strategy
  - fix percentage offset
  - fix Redis/Memcache dependency issue
