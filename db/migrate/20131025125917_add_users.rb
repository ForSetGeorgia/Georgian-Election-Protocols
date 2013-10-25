class AddUsers < ActiveRecord::Migration
  def up

    [
      ["tutakvaratskhelia@yahoo.com", "yep3a22jup"],
      ["iraklius.meursault@gmail.com", "ra8hebu9re"],
      ["confusedmonkeyyy@gmail.com", "frup5uyu7a"],
      ["giorgi.navdarashvili2013@ens.tsu.edu.ge", "xane23munu"],
      ["nino_mik@hotmail.com", "fre7a89uvu"],
      ["vachnadze_g@yahoo.com", "kegada39z9"],
      ["ananochaladze@gmail.com", "phafup4aqa"],
      ["d.shanidze@ydc.ge", "8tapruyune"],
      ["tornike.zoidze@yahoo.com", "sw8p5ach4s"],
      ["natia_natia89@yahoo.com", "wuyened5sw"],
      ["mkapanadze@rocketmail.com", "jutamudes5"],
      ["abramishvili.tata@yahoo.com", "de8repuya4"],
      ["gujabidzeketevani@gmail.com", "sem3paswes"],
      ["giopapunaishvili@yahoo.com", "gedrud4qep"],
      ["katiekartvel@gmail.com", "yu8ucrequr"],
      ["manchosposta@gmail.com", "chedruph5p"],
      ["butkhuzimariam@yahoo.com", "thereq7men"],
      ["ani_zurashvili@yahoo.com", "fus6e9tuth"],
      ["ditokaulashvili@yahoo.com", "j4gepa3ehe"],
      ["jabaarabashvili@gmail.com", "wubr8kutra"],
      ["gvancashishinashvili@yahoo.com", "t5es8upru3"],
      ["nino.kavteladze@mail.ru", "keq65erabe"],
      ["megi.benia@yahoo.com", "bujac9udeh"],
      ["vaniko93@gmail.com", "mufecr4vuc"],
      ["nino.pa@valoran.ge", "h65r6taxaf"],
      ["ana_mamaladze@yahoo.com", "yehuwra5tu"],
      ["konstantine_9090@yahoo.com", "b8chedrapu"],
      ["lobiladze@gmail.com", "f4ebache4e"],
      ["elene.lobiladze.1@iliauni.edu.ge", "3hu2uq4yuk"],
      ["caqtus91@yahoo.com", "wrefr9quke"]
    ].each do |x|
      User.create(:email => x[0], :password => x[1], :role => 0)
    end

  end

  def down
  end
end
