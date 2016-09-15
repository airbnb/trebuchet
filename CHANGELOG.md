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
