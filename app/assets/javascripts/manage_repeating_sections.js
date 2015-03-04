// This widget manages the adding and removing of repeating fields.
// There are a lot of assumptions about the structure of the classes and elements.
// These assumptions are reflected in the MultiValueInput class.
//
(function($){
  $.widget( "sipity.manage_sections", {
    options: {
      change: null,
      add: null,
      remove: null
    },

    _create: function() {
      this.element.addClass("managed");
      $('.repeat', this.element).addClass("input-append");
      this.adder = $("<button class=\"btn btn-success add\" id=\"section_add_button\"><i class=\"icon-white icon-plus\"></i><span>Add</span></button>");
      this.remover = $("<button class=\"btn btn-danger remove\"><i class=\"icon-white icon-minus\"></i><span>Remove</span></button>");
      this.tableControls = $('.table-controls', this.element);
      this.cannotAddNotification = $('<div class="alert alert-warning warning">You cannot add multiple empty entries.</div>');

      $('.repeat:not(:last-child) .row-controls', this.element).append(this.remover);
      $('.repeat:last', this.element).append(this.adder);

      this._on( this.element, {
        "click .remove": "remove_from_list",
        "click .add": "add_to_section_list"
      });

      var $last_line = $('.repeat', this.element).last();
      var $last_element_val = $last_line.children('td.name').first().children('div').children('input').val();
      if( $last_element_val ){
        $( '#section_add_button').trigger( 'click' );
      }
    },

    add_to_section_list: function( event ) {
      event.preventDefault();
      console.log('add_to_section_list');

      var $activeField = $(event.target).parents('.repeat'),
          $activeFieldControls = $activeField.children('.row-controls'),
          $lastNameField = $activeField.children('td.name').first().children('div').children('input'),
          $newField = $activeField.clone(),
          $listing = $activeField.parent(),
          $removeControl = this.remover.clone(),
          $warning = this.tableControls.children('.warning'),
          warningCount = $warning.length,
          rowNumber = $('.repeat').length; // TODO: this is too simplistic to keep track of an ID

      if ($lastNameField.val() === '') {
        if (warningCount === 0) {
          this.tableControls.prepend(this.cannotAddNotification);
        }
      } else {
        $warning.remove();
        $('.add', $activeFieldControls).remove();
        $('.remove', $activeFieldControls).remove();
        $activeFieldControls.prepend($removeControl);

        $newChild1 = $newField.children('td.name')
                       .first()
                       .children('div')
                       .children('input')
                       .attr('id', 'work_collaborators__attributes_' + rowNumber + '_name')
                       .attr('name', 'work[collaborators_attributes][' + rowNumber + '][name]');
        $newChild2 = $newField
                       .children('td.role')
                       .last()
                       .children('div')
                       .children('select')
                       .attr('id', 'work_collaborators_attributes_' + rowNumber + '_role')
                       .attr('name', 'work[collaborators_attributes][' + rowNumber + '][role]');
        $newChild3 = $newField
                       .children('td.review')
                       .last()
                       .children('div')
                       .children('select')
                       .attr('id', 'work_collaborators_attributes_' + rowNumber + '_responsible_for_review')
                       .attr('name', 'work[collaborators_attributes][' + rowNumber + '][responsible_for_review]');
        $newChild4 = $newField
                       .children('td.contact-information')
                       .first()
                       .children('span')
                       .first()
                       .children('div')
                       .children('input')
                       .attr('id', 'work_collaborators__attributes_' + rowNumber + '_netid')
                       .attr('name', 'work[collaborators_attributes][' + rowNumber + '][netid]');
        $newChild5 = $newField
                       .children('td.contact-information')
                       .first()
                       .children('span')
                       .last()
                       .children('div')
                       .children('input')
                       .attr('id', 'work_collaborators__attributes_' + rowNumber + '_email')
                       .attr('name', 'work[collaborators_attributes][' + rowNumber + '][email]');

        $newChild1.val('');
        $newChild2.val('');
        $newChild3.children("option[value='No']").attr("selected","selected");
        $newChild4.val('');
        $newChild5.val('');

        $activeField.children('button').remove();
        $listing.append($newField);
        $('.remove', $newField).remove();
        $newChild1.first().focus();
        this._trigger("add");
      }
    },

    remove_from_list: function( event ) {
      event.preventDefault();

      $(event.target)
        .parents('.repeat')
        .remove();

      this._trigger("remove");
    },

    _destroy: function() {
      this.actions.remove();
      $('.repeat', this.element).removeClass("input-append");
      this.element.removeClass( "managed" );
    }
  });
})(jQuery);
