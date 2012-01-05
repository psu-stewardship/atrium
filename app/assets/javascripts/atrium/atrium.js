//= require chosen.jquery
//= require ckeditor-jquery
//= include jquery.colorbox
//= require jquery.jeditable
//= require ckeditor/jquery.generateId
//= require ckeditor/jquery.jeditable.ckeditor



(function($){
  $(document).ready(function(){

    CKEDITOR.config.toolbar_Basic = [ [ 'Source', '-', 'Bold', 'Italic' ] ];

    $('select.chosen').chosen();

    $('.jquery-ckeditor').ckeditor(
        {
      toolbar: [
        ['Cut','Copy','Paste','PasteText','PasteFromWord'],
        ['Bold','Italic','Underline','Strike'],
        ['Format','-','NumberedList','BulletedList','Blockquote'],
        ['Link','Unlink','Anchor','-','SelectAll','RemoveFormat'],
        ['Source','ShowBlocks','Maximize']
      ]
    }
    );

    $('.sortable').sortable({
      update: function(e, ui){
        var $target        = $(e.target),
            orderedItems   = {},
            resourceURL    = $target.attr('data-resource'),
            childTag       = $target.children().first()[0].nodeName.toLowerCase(),
            primaryLabel   = $target.attr('data-primary-label'),
            secondaryLabel = $target.attr('data-secondary-label');

        $(childTag, e.target).each(function(index, element){
          var objectId = $(element).attr('data-id');
          orderedItems[objectId] = (index + 1);
        });

        $.ajax({
          type: 'POST',
          url: resourceURL,
          data: {collection: orderedItems},
          success: function(data, statusCode){
            if (childTag == 'li'){
              $target.effect('highlight', {}, 1500);
            } else {
              $target.parents('fieldset').effect('highlight', {}, 1500);
            }

            if (primaryLabel !== undefined){
              $('td.label', $target).text(secondaryLabel);        // This could be implemented better
              $('td.label', $target).first().text(primaryLabel);  //
            }
          }
        });
      }
    });

    $('.select_colorbox').colorbox({
      width:'880px',
      height:'80%',
      iframe:true,
      onClosed:function(){
        var url = $(this).attr('action');
        $.ajax({
          type: 'GET',
          url: url,
          dataType: 'html',
          cache: true,
          beforeSend: function() {
            $('#cboxLoadedContent').empty();
            $('#cboxLoadingGraphic').show();
          },
          complete: function() {
            $('#cboxLoadingGraphic').hide();
          },
          success: function(data) {
            $('#show_selected').html(data);
            $('#catalog-form').show();
          }
        });
      }
    });

    $('.description_colorbox').colorbox({
      width:'880px',
      height:'80%',
      iframe:true,
      onClosed:function(){
        var url = $(this).attr('action');
        $.ajax({
          type: 'GET',
          url: url,
          dataType: 'html',
          cache: true,
          beforeSend: function() {
            $('#cboxLoadedContent').empty();
            $('#cboxLoadingGraphic').show();
          },
          complete: function() {
            $('#cboxLoadingGraphic').hide();
          },
          success: function(data) {
            var html= loadMore(data);
            $('#show_description').html(html);
            $('#catalog-form').show();


          }
        });
      }
    });

    function loadMore(response) {
        var $html = $(response);
        $html.find('a.description_colorbox').colorbox({ width: '960px', height: '90%', iframe: true });
        return $html;
    }


    //$('.description').hide();
    $('.add_description').click(function(){
        var $this = $(this);
        $this.parent()
          .children('.description')
          .slideToggle(300, function(){
            if ($this.text() == 'Add Description'){
              $this.text('Hide Description');
            }else{
              $this.text('Add Description');
            }
          });
    });

    $("a.destroy_description", this).live("click", function(e) {
       var $descNode = $(this).closest('li')
       var url = $(this).attr('action');
       $.ajax({
         type: "DELETE",
         url: url,
         dataType: "html",
         beforeSend: function() {
   			$descNode.animate({'backgroundColor':'#fb6c6c'},300);
         },
         success: function() {
           $descNode.slideUp(300,function() {
             $descNode.remove();
           });
         }
       });
     });

     $('.edit-text').editable(submitEditableText,{
         indicator : 'Saving...',
         tooltip   : 'Click to edit...'
     });

     function submitEditableText(value, settings) {
       var edits = new Object();
       var result = value;
       edits[settings.name] = [value];
       var params = $('div.edit-text').attr("data-column-name")+"="+value;
        var returned = $.ajax({
         type: "PUT",
         url: $('div.edit-text').attr("data-update-uri"),
         dataType: "html",
         data: params,
         success: function(data){
           $(".div.edit-text").text(value)
         },
         error: function(xhr, textStatus, errorThrown){
     		$.noticeAdd({
             inEffect:               {opacity: 'show'},      // in effect
             inEffectDuration:       600,                    // in effect duration in milliseconds
             stayTime:               6000,                   // time in milliseconds before the item has to disappear
             text:                   'Your changes failed'+ xhr.statusText + ': '+ xhr.responseText,
             stay:                   true,                  // should the notice item stay or not?
             type:                   'error'                // could also be error, success
            });
         }
      });
      return value;
     }

     function submitEditableTextArea(value, settings) {
       var edits = new Object();
       var result = value;
       edits[settings.name] = [value];
       var params = $('div.edit-textarea').attr("data-column-name")+"="+value;
        var returned = $.ajax({
         type: "PUT",
         url: $('div.edit-textarea').attr("data-update-uri"),
         dataType: "html",
         data: params,
         success: function(data){
           $(".div.edit-text").text(value)
         },
         error: function(xhr, textStatus, errorThrown){
     		$.noticeAdd({
             inEffect:               {opacity: 'show'},      // in effect
             inEffectDuration:       600,                    // in effect duration in milliseconds
             stayTime:               6000,                   // time in milliseconds before the item has to disappear
             text:                   'Your changes failed'+ xhr.statusText + ': '+ xhr.responseText,
             stay:                   true,                  // should the notice item stay or not?
             type:                   'error'                // could also be error, success
            });
         }
      });
      return value;
     }

     $('.edit-textarea').editable(submitEditableTextArea, {
          method    : "PUT",
          type      : "ckeditor",
          submit    : "OK",
          cancel    : "Cancel",
          placeholder : "click to edit description",
          onblur    : "ignore",
          name      : "textarea",
          id        : "field_id",
          indicator : 'Saving...',
          tooltip   : 'Click to edit...',
          height    : "100",
          ckeditor  : { toolbar:
                        [
                            ['Bold', 'Italic', '-', 'NumberedList', 'BulletedList', '-', 'Link', 'Unlink', '-', 'linkItem'],
                            ['Cut','Copy','Paste','PasteText','PasteFromWord','-','Print', 'SpellChecker', 'Scayt'],
                            ['UIColor', 'PageBreak'], ['Source'], ['Maximize', 'ShowBlocks','-','About']
                        ]
                      }
     });

     $("div.content").hide();

     $("a.heading").click(function(){
        $(this).siblings(".intro").toggle()
        $(this).next("div.content").slideToggle(300);
        $(this).text($(this).text() == '[Read the complete essay]' ? '[Hide essay]' : '[Read the complete essay]');
     });

  });
})(jQuery);
