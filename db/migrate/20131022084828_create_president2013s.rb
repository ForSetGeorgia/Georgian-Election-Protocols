class CreatePresident2013s < ActiveRecord::Migration
  def change
    create_table :president2013s do |t|
      t.string :region
      t.integer :district_id
      t.string :district_name
      t.integer :precinct_id
      t.integer :attached_precinct_id
      t.integer :num_possible_voters
      t.integer :num_special_voters
      t.integer :num_at_12
      t.integer :num_at_17
      t.integer :num_votes
      t.integer :num_ballots
      t.integer :num_invalid_votes
      t.integer :num_valid_votes
      t.integer :logic_check_fail
      t.integer :logic_check_difference
      t.integer :more_ballots_than_votes_flag
      t.integer :more_ballots_than_votes
      t.integer :more_votes_than_ballots_flag
      t.integer :more_votes_than_ballots
      t.integer :'1 - Tamaz Bibiluri'
      t.integer :'2 - Giorgi Liluashvili'
      t.integer :'3 - Sergo Javakhidze'
      t.integer :'4 - Koba Davitashvili'
      t.integer :'5 - Davit Bakradze'
      t.integer :'6 - Akaki Asatiani'
      t.integer :'7 - Nino Chanishvili'
      t.integer :'8 - Teimuraz Bobokhidze'
      t.integer :'9 - Shalva Natelashvili'
      t.integer :'10 - Giorgi Targamadze'
      t.integer :'11 - Levan Chachua'
      t.integer :'12 - Nestan Kirtadze'
      t.integer :'13 - Giorgi Chikhladze'
      t.integer :'14 - Nino Burjanadze'
      t.integer :'15 - Zurab Kharatishvili'
      t.integer :'16 - Mikheil Saluashvili'
      t.integer :'17 - Kartlos Gharibashvili'
      t.integer :'18 - Mamuka Chokhonelidze'
      t.integer :'19 - Avtandil Margiani'
      t.integer :'20 - Nugzar Avaliani'
      t.integer :'21 - Mamuka Melikishvili'
      t.integer :'22 - Teimuraz Mzhavia'
      t.integer :'41 - Giorgi Margvelashvili'

      t.timestamps
    end
    
    add_index :president2013s, :region
    add_index :president2013s, :district_id
    add_index :president2013s, :precinct_id

  end
end
