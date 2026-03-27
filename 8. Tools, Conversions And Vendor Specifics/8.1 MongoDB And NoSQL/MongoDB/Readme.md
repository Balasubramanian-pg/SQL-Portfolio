# MongoDB Cheat Sheet
This is a no bullshit, cheat sheet for a quick reference

**Basics**

* `show dbs`
* `use mydb`
* `show collections`

**CRUD**

* Insert: `db.users.insertOne({name:"A", age:30})`
* Find: `db.users.find({age:{$gt:25}})`
* Update: `db.users.updateOne({name:"A"}, {$set:{age:31}})`
* Delete: `db.users.deleteOne({name:"A"})`

**Query operators**

* `$gt $lt $gte $lte`
* `$in $nin`
* `$and $or`
* `$exists`

**Projection**

* `db.users.find({}, {name:1, _id:0})`

**Sorting & limiting**

* `.sort({age:-1}).limit(5).skip(5)`

**Aggregation**

* `$match`
* `$group`
* `$sum $avg $count`
* `$sort`
* `$project`

**Index**

* `db.users.createIndex({email:1})`

SQL brain tip: collections = tables, documents = rows, but schema stays chill.

Cool, round two. Slightly spicier, still practical.

**Aggregation examples**

* Group:
  `db.orders.aggregate([{ $group:{ _id:"$userId", total:{ $sum:"$amount"}}}])`
* Filter early: `$match` first, always. Performance 101.

**Joins (lookup)**
`$lookup` = LEFT JOIN energy
`from`, `localField`, `foreignField`, `as`

**Distinct**

* `db.users.distinct("country")`

**Indexes**

* Compound: `{userId:1, createdAt:-1}`
* Check usage: `db.collection.explain("executionStats").find(...)`

**Schema moves**

* Add field: `$set`
* Remove field: `$unset`

Rule from the old days still holds: model for reads, not vibes.
