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
    sum += pres['1 - Tamaz Bibiluri'].present? ? pres['1 - Tamaz Bibiluri'] : 0
    sum += pres['2 - Giorgi Liluashvili'].present? ? pres['2 - Giorgi Liluashvili'] : 0
    sum += pres['3 - Sergo Javakhidze'].present? ? pres['3 - Sergo Javakhidze'] : 0
    sum += pres['4 - Koba Davitashvili'].present? ? pres['4 - Koba Davitashvili'] : 0
    sum += pres['5 - Davit Bakradze'].present? ? pres['5 - Davit Bakradze'] : 0
    sum += pres['6 - Akaki Asatiani'].present? ? pres['6 - Akaki Asatiani'] : 0
    sum += pres['7 - Nino Chanishvili'].present? ? pres['7 - Nino Chanishvili'] : 0
    sum += pres['8 - Teimuraz Bobokhidze'].present? ? pres['8 - Teimuraz Bobokhidze'] : 0
    sum += pres['9 - Shalva Natelashvili'].present? ? pres['9 - Shalva Natelashvili'] : 0
    sum += pres['10 - Giorgi Targamadze'].present? ? pres['10 - Giorgi Targamadze'] : 0
    sum += pres['11 - Levan Chachua'].present? ? pres['11 - Levan Chachua'] : 0
    sum += pres['12 - Nestan Kirtadze'].present? ? pres['12 - Nestan Kirtadze'] : 0
    sum += pres['13 - Giorgi Chikhladze'].present? ? pres['13 - Giorgi Chikhladze'] : 0
    sum += pres['14 - Nino Burjanadze'].present? ? pres['14 - Nino Burjanadze'] : 0
    sum += pres['15 - Zurab Kharatishvili'].present? ? pres['15 - Zurab Kharatishvili'] : 0
    sum += pres['16 - Mikheil Saluashvili'].present? ? pres['16 - Mikheil Saluashvili'] : 0
    sum += pres['17 - Kartlos Gharibashvili'].present? ? pres['17 - Kartlos Gharibashvili'] : 0
    sum += pres['18 - Mamuka Chokhonelidze'].present? ? pres['18 - Mamuka Chokhonelidze'] : 0
    sum += pres['19 - Avtandil Margiani'].present? ? pres['19 - Avtandil Margiani'] : 0
    sum += pres['20 - Nugzar Avaliani'].present? ? pres['20 - Nugzar Avaliani'] : 0
    sum += pres['21 - Mamuka Melikishvili'].present? ? pres['21 - Mamuka Melikishvili'] : 0
    sum += pres['22 - Teimuraz Mzhavia'].present? ? pres['22 - Teimuraz Mzhavia'] : 0
    sum += pres['41 - Giorgi Margvelashvili'].present? ? pres['41 - Giorgi Margvelashvili'] : 0

    return sum
  end
end
