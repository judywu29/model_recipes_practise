Rails Model practise:
================================

I will try to practise all of the association used in my work and use some good recipse I learnt from books like
"Anti Pattern", "Rails Recipes". 

 - has_many through VS has_and_belongs_to_many: used on Subscription, Reader and Magzine Models
 
   Sometimes we need a join model which has its own attributes. and then we can also add some callback, validations on it. 
   Also, we can build an easy accessor 
   
   		class Subscription < ActiveRecord::Base
  			belongs_to :reader
  			belongs_to :magzine
		end
		
		class Reader < ActiveRecord::Base
  			has_many :subscriptions
  			has_many :magzines, through: :subscriptions
		end
		
		class Magzine < ActiveRecord::Base
  			has_many :subscriptions
  			has_many :readers, through: :subscriptions
		end
	
	- Named scope, used on Subscription Model
	
	It's a good way as the macro-style class methods: 
	
	Usually we don't use the queries in the controllers, we can define named scopes in the model:
	
		scope :annual_subscriptions, ->{ where length_in_issues: 12 }
	
		2.2.1 :001 > Subscription.annual_subscriptions
  		Subscription Load (0.6ms)  SELECT "subscriptions".* FROM "subscriptions" WHERE "subscriptions"."length_in_issues" = ? 
  		 [["length_in_issues", 12]]
 		=> #<ActiveRecord::Relation [#<Subscription id: 1, last_renewal_on: "2015-09-17", length_in_issues: 12, reader_id: 1, 
 		magzine_id: 1, created_at: "2015-09-26 04:17:40", updated_at: "2015-09-26 04:18:21">, #<Subscription id: 2, 
 		last_renewal_on: "2015-09-17", length_in_issues: 12, reader_id: nil, magzine_id: nil, created_at: "2015-09-26 04:42:41", 
 		updated_at: "2015-09-26 04:42:41">]> 
 	
 	with argument:
 	 
 		scope :subscribed_before, ->(time) { where 'last_renewal_on < ? ', time }
 		
 		Subscription.subscribed_before(Time.zone.now)
  		Subscription Load (2.6ms)  SELECT "subscriptions".* FROM "subscriptions" WHERE (last_renewal_on < '2015-09-26 15:15:46.872959' )
 		=> #<ActiveRecord::Relation [#<Subscription id: 1, last_renewal_on: "2015-09-17", length_in_issues: 12, reader_id: 1, 
 		magzine_id: 1, created_at: "2015-09-25 18:17:40", updated_at: "2015-09-25 18:18:21">, #<Subscription id: 2, 
 		last_renewal_on: "2015-09-17", length_in_issues: 12, reader_id: nil, magzine_id: nil, created_at: "2015-09-25 18:42:41", 
 		updated_at: "2015-09-25 18:42:41">]> 
 		
 	- use default_scope(), used on Magzine Model
 	
 		Magzine.all
  		Magzine Load (0.5ms)  SELECT "magzines".* FROM "magzines"
 		=> #<ActiveRecord::Relation [#<Magzine id: 1, title: "Men and kittens", created_at: "2015-09-25 18:15:48", 
 		updated_at: "2015-09-26 05:26:44", published: false>]> 
 		
 		default_scope { where(published: true) }
 		It will apply to all of the queries. Actually this is not used widely. On our first attempt to find the record we just created, 
 		the query responds as if the record doesn’t exist. When we bypass the default scope with the unscoped() method, the record is returned.
 		
 		Magzine.all
  		Magzine Load (0.4ms)  SELECT "magzines".* FROM "magzines" WHERE "magzines"."published" = ?  [["published", "t"]]
 		=> #<ActiveRecord::Relation []> 
 		
 	- About collection proxy: used on Magzine Model
 	
 	collection proxy is a wrappers around the collections, allowing them to be lazily loaded and extended. 
 	We can add behaviors on the collection proxy like this: 
	 	
	 	by passing a block to the declaration of the has_many() association: 
	 	
		 	has_many :readers, through: :subscriptions do
			    def below_average(age)
			      where('age < ?', age)
			    end
		  	end
	 	
	 		Magzine.first.readers.below_average(28)
	  		Magzine Load (0.1ms)  SELECT  "magzines".* FROM "magzines"  ORDER BY "magzines"."id" ASC LIMIT 1
	  		Reader Load (0.4ms)  SELECT "readers".* FROM "readers" INNER JOIN "subscriptions" ON "readers"."id" = "subscriptions"."reader_id" 
	  		WHERE "subscriptions"."magzine_id" = ? AND (age < 28)  [["magzine_id", 1]]
	 		=> #<ActiveRecord::AssociationRelation [#<Reader id: 1, name: "jane", created_at: "2015-09-25 18:16:05", 
	 		updated_at: "2015-09-26 05:44:47", age: 25>]> 
 		
 		Or we can create a module(put it under the concerns) and then we extend it like:
 		
 			has_many :readers, through: :subscriptions, extend: ReaderFinder
 		
 		we use it the same way
 		
 	- Polymorphic Associations,  used on Address, Person and Company Models
 	
 			class Address < ActiveRecord::Base
  				belongs_to :addressable, polymorphic: true
			end
			
			t.references :addressable, polymorphic: true, index: true
			
			class Company < ActiveRecord::Base
  				has_many :addresses, as: :addressable
  
			end
			
			class Person < ActiveRecord::Base
  				has_many :addresses, as: :addressable
			end
 		
			2 columns have been added: addressable_id and addressable_type
			
			Address.all
  			Address Load (0.3ms)  SELECT "addresses".* FROM "addresses"
 			=> #<ActiveRecord::Relation [#<Address id: 1, street_address1: "15 queens road", street_address2: nil, city: "melbourne", 
 			state: nil, country: "Australia", postcode: "3004", addressable_id: 1, addressable_type: "Person", created_at: "2015-09-26 06:10:38", updated_at: "2015-09-26 06:10:38">,
 			 
 			 #<Address id: 2, street_address1: "15 bourke st", street_address2: nil, city: "melbourne", state: nil, country: "Australia", 
 			 postcode: "3000", addressable_id: 1, addressable_type: "Company", created_at: "2015-09-26 06:11:54", 
 			 updated_at: "2015-09-26 06:11:54">]>
 	
 	- use paper-trail to track changes to our models: used on Chapter Model
 	
 	This is useful when we have to correct our mistakes we made on the data. or Sometimes users need to be able to compare two versions 
 	of a piece of data to see what has changed.
 	
 	after installing the gem and applied to our model, now can we use the methods privided: 
 			
 	actually this gem created a table called 'versions' to maintain the tracks/versions: 
 			
 			Chapter.create(title: "legacy", body: "wonderful history")
   			(0.1ms)  begin transaction
  			SQL (1.2ms)  INSERT INTO "chapters" ("title", "body", "created_at", "updated_at") VALUES (?, ?, ?, ?)  [["title", "legacy"], 
  			["body", "wonderful history"], ["created_at", "2015-09-26 16:33:02.008622"], ["updated_at", "2015-09-26 16:33:02.008622"]]
  			SQL (0.8ms)  INSERT INTO "versions" ("event", "created_at", "item_id", "item_type") VALUES (?, ?, ?, ?)  [["event", "create"], 
  			["created_at", "2015-09-26 16:33:02.008622"], ["item_id", 1], ["item_type", "Chapter"]]
   			(1.1ms)  commit transaction
 			=> #<Chapter id: 1, title: "legacy", body: "wonderful history", created_at: "2015-09-26 06:33:02", updated_at: "2015-09-26 06:33:02">
 			
 			c.versions
 			=> #<ActiveRecord::Associations::CollectionProxy [#<PaperTrail::Version id: 1, item_type: "Chapter", item_id: 1, event: "create", 
 			whodunnit: nil, object: nil, created_at: "2015-09-26 06:33:02">, 
 			#<PaperTrail::Version id: 2, item_type: "Chapter", item_id: 1, event: "update", whodunnit: nil, 
 			object: "---\nid: 1\ntitle: legacy\nbody: wonderful history\ncr...", created_at: "2015-09-26 06:34:26">]>
 			
 	- 
   
