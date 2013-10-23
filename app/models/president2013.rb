class President2013 < ActiveRecord::Base


  def calculate_valid_votes
    sum = 0
    sum += self.num_votes.present? ? self.num_votes : 0
    sum -= self.num_invalid_votes.present? ? self.num_invalid_votes : 0
    
    return sum
  end
  
  def calculate_logic_check_fail
    calculate_valid_votes - sum_party_votes == 0 ? false : true
  end
  
  def calculate_logic_check_difference
    calculate_valid_votes - sum_party_votes
  end
  
  def calculate_more_ballots_than_votes_flag
    calculate_valid_votes > sum_party_votes ? true : false
  end
  
  def calculate_more_ballots_than_votes
    if calculate_more_ballots_than_votes_flag
      calculate_valid_votes - sum_party_votes
    else
      0
    end
  end
  
  def calculate_more_votes_than_ballots_flag
    calculate_valid_votes < sum_party_votes ? true : false
  end
  
  def calculate_more_votes_than_ballots
    if calculate_more_votes_than_ballots_flag
      (calculate_valid_votes - sum_party_votes).abs
    else
      0
    end
  end
  
  def sum_party_votes
    sum = 0
    sum += self['1 - Tamaz Bibiluri'].present? ? self['1 - Tamaz Bibiluri'] : 0
    sum += self['2 - Giorgi Liluashvili'].present? ? self['2 - Giorgi Liluashvili'] : 0
    sum += self['3 - Sergo Javakhidze'].present? ? self['3 - Sergo Javakhidze'] : 0
    sum += self['4 - Koba Davitashvili'].present? ? self['4 - Koba Davitashvili'] : 0
    sum += self['5 - Davit Bakradze'].present? ? self['5 - Davit Bakradze'] : 0
    sum += self['6 - Akaki Asatiani'].present? ? self['6 - Akaki Asatiani'] : 0
    sum += self['7 - Nino Chanishvili'].present? ? self['7 - Nino Chanishvili'] : 0
    sum += self['8 - Teimuraz Bobokhidze'].present? ? self['8 - Teimuraz Bobokhidze'] : 0
    sum += self['9 - Shalva Natelashvili'].present? ? self['9 - Shalva Natelashvili'] : 0
    sum += self['10 - Giorgi Targamadze'].present? ? self['10 - Giorgi Targamadze'] : 0
    sum += self['11 - Levan Chachua'].present? ? self['11 - Levan Chachua'] : 0
    sum += self['12 - Nestan Kirtadze'].present? ? self['12 - Nestan Kirtadze'] : 0
    sum += self['13 - Giorgi Chikhladze'].present? ? self['13 - Giorgi Chikhladze'] : 0
    sum += self['14 - Nino Burjanadze'].present? ? self['14 - Nino Burjanadze'] : 0
    sum += self['15 - Zurab Kharatishvili'].present? ? self['15 - Zurab Kharatishvili'] : 0
    sum += self['16 - Mikheil Saluashvili'].present? ? self['16 - Mikheil Saluashvili'] : 0
    sum += self['17 - Kartlos Gharibashvili'].present? ? self['17 - Kartlos Gharibashvili'] : 0
    sum += self['18 - Mamuka Chokhonelidze'].present? ? self['18 - Mamuka Chokhonelidze'] : 0
    sum += self['19 - Avtandil Margiani'].present? ? self['19 - Avtandil Margiani'] : 0
    sum += self['20 - Nugzar Avaliani'].present? ? self['20 - Nugzar Avaliani'] : 0
    sum += self['21 - Mamuka Melikishvili'].present? ? self['21 - Mamuka Melikishvili'] : 0
    sum += self['22 - Teimuraz Mzhavia'].present? ? self['22 - Teimuraz Mzhavia'] : 0
    sum += self['41 - Giorgi Margvelashvili'].present? ? self['41 - Giorgi Margvelashvili'] : 0

    return sum
  end
end
