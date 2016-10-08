$(document).ready(function(){




  var votesum_edit = $('#votesum_edit');
  if (votesum_edit.length)
  {
    var vch = {s: votesum_edit.children('.s'), f: votesum_edit.children('.f')};

    var input = $('#president2013_num_invalid_votes'),
    offset = input.offset();
    votesum_edit.css({left: offset.left + input.outerWidth(), top: offset.top});

    var partyinputs = $('input[class="edit_party"]').add(input);
    partyinputs.bind('keyup change', function ()
    {
      var sum = 0;
      partyinputs.each(function ()
      {
        sum += +$(this).val();
      });
      vch.s[0].innerHTML = sum;
      check_values();
    });

    $('#president2013_num_votes').bind('keyup change', function ()
    {
      vch.f[0].innerHTML = +$(this).val();
      check_values();
    });

    function check_values ()
    {
      if (vch.s[0].innerHTML == vch.f[0].innerHTML && +vch.f[0].innerHTML > 0)
      {
        votesum_edit.addClass('same');
      }
      else
      {
        votesum_edit.removeClass('same');
      }
    }
  }


  $('.create_migration').click(function(){
    console.log('create_migration click');
    var ths = this;
    var link = $(ths).closest('.create_migration_link');
    var processing = $(link).next('.create_migration_processing');
    var success = $(processing).next('.create_migration_success');
    var error = $(success).next('.create_migration_error');

    $.ajax({
      url: "/en/admin/election_data/create_migration/" + $(this).data('id')
    }).done(function(resp) {
      //resp = {success, msg, data}
      console.log(resp);

      if (resp.success){
        // show processing message
        $(link).hide(300, function(){
          $(processing).show(300);
        })

        // start push
        console.log('posting to election map site');
        $.ajax({
          url: resp.data.migration_url,
          data: {
            file_url: resp.data.file_url,
            precincts_completed: resp.data.precincts_completed,
            precincts_total: resp.data.precincts_total,
            event_id: resp.data.event_id,
            respond_to_url: resp.data.respond_to_url
          }
        }).done(function(resp){
          console.log('back from map site');
          if (resp.success){
            console.log('success');
            // show success message
            $(processing).hide(300, function(){
              $(success).show(300);
            })
          } else {
            console.log('error');
            // show error message
            $(processing).hide(300, function(){
              $(error).show(300);
            })
          }
          // save the migration notification
          $.ajax({
            url: gon.notification_url,
            data: {
              file_url: resp.file_url,
              success: resp.success,
              msg: resp.msg
            }
          }).done(function(resp){
            console.log('all done!');
          });
        });
      }
    });

    return false;
  });

});
