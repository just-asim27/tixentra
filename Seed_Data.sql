---SEED DATA

insert into organizer values(1,'Ali','ali01gmail.com','9505-1244580101','ali01','2020-01-01',DEFAULT,'0300-2412908'),(2,'Sara','sara02gmail.com','9505-1345578100','sara02','2019-02-22',DEFAULT,'0327-2412018'),(3,'Ahmed','ahmed03gmail.com','9506-1295785102','ahmed03','2010-07-29',DEFAULT,'0304-2417200'),(4,'Amna','amna04gmail.com','9105-1222578101','amna04','2012-05-01',DEFAULT,'0300-2442208'),(5,'Arish','arish05gmail.com','9505-1244677101','arish05','2014-07-01',DEFAULT,'0304-2412768');

insert into buyer values(1,'Mobeen','mobeen01@gmail.com','9510-1244580101','mobeen01','1990-07-01',DEFAULT,'0327-2412908'),(2,'Umar','umar02@gmail.com','9510-1345578100','umar02','2019-02-12',DEFAULT,'0300-2412018'),(3,'Haya','haya03gmail.com','9510-1295785122','haya03','2018-07-19',DEFAULT,'0304-2417213'),(4,'Ayesha','ayesha04gmail.com','9115-1222678101','ayesha04','2017-05-23',DEFAULT,'0304-2442208'),(5,'William','william05gmail.com','9515-1244676101','willian05','2001-07-11',DEFAULT,'0304-2417668');   

insert into organization values(1,'Wali Enterprise','wali01@gmail.com','0327-2412918','wali01','walienterprise.com',DEFAULT,'owner','reg01','gujranwala');

insert into venue values(1,'English Tea House','gujranwala','pakistan',30,'Open Ground','next to Spice Bazaar'),(2,'Gift Uni','gujranwala','pakistan',50,'Auditorium','pindi bypass');

insert into seat values(1,'row01',01,'section01','VIP',1),(2,'row01',02,'section01','VIP',1),(3,'row01',01,'section01','VIP',2),(4,'row01',01,'section01','VIP',2);

insert into event values(1,'Tixentra Opening','Presenting you design and implementation of a Dynamic Event Ticketing and Anti-Scalping System Tixentra aimed at addressing common issues in existing ticketing platforms such as double booking, unfair ticket resale, and lack of transparency in ownership. The system focuses on maintaining data integrity and enforcing fairness through database-level constraints and transaction management.','2026-08-01 09:00:00','2026-08-05 18:00:00','2026-07-01 00:00:00','2026-07-25 23:59:59', 5000.00,'Active',30,TRUE,10.50,15.00,500,1000,18,150.00,25.50,25000.00,1,1,1);   
   
insert into theater values(1,'Tixentra','English');

insert into theater_genre values(1,'Tragedy');

insert into theater_director values(1,'Sumaiya');

insert into theater_writer values(1,'Sumaiya');

insert into theater_cast values(1,'Madifa');

insert into sports values(1,'Cricket','yes','no','match');

insert into concert values(1);

insert into concert_artist values(1,'Atif Asalam');

insert into concert_genre values(1,'Pop');

insert into ticket values(1,400,'Available','2026-07-15 23:59:59',1,1);

insert into transaction values(1,4500.0,'Card',DEFAULT,'Completed');

insert into resale_payment values(1,300,100,1,1,1,2);

insert into initial_payment values(1,1,1,1);

insert into event_payment values(1,1,1,1);

insert into refund values(1,300,'Card','Pending','NC',DEFAULT,1);

insert into buyer_review values(1,1,'NC',DEFAULT,'2026-07-25 23:59:59',1,1);

insert into organization_review values(1,1,'NO COMMENT',DEFAULT,'2026-07-29 23:59:59',1,1,1);

insert into reservation_history values(1,1,DEFAULT,'2026-07-30 23:59:59','Active');

insert into ownership_history values(1,1,'2026-07-19 23:59:59','2026-07-27 13:59:59','false');

insert into resale_listing_history values(1,1,350.2,'Listed',DEFAULT);

insert into application_history values(1,1,DEFAULT,'Pending');