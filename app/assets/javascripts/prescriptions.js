$(document).on('turbolinks:load', function() {
  
  $(function () {
    var today = new moment();
    var expiryDate = new moment().add(30, 'days');
    $('#prescription_prescribed_date').datetimepicker({
      format: 'DD/MM/YYYY',
      date: today
    });
    $('#prescription_expiry_date').datetimepicker({
      format: 'DD/MM/YYYY',
      date: expiryDate,
      useCurrent: false, //Important! See issue #1075
    });
    $("#prescription_prescribed_date").on("dp.change", function (e) {
      $('#prescription_expiry_date').data("DateTimePicker").minDate(e.date);
      $('#prescription_expiry_date').data("DateTimePicker").date(e.date.add(30,'days'));
    });
    $("#prescription_expiry_date").on("dp.change", function (e) {
        $('#prescription_prescribed_date').data("DateTimePicker").maxDate(e.date);
    });
  });

  $('.selectpicker').selectpicker();

  $('.quantity_supply_lots').on('cocoon:after-insert', function(e, insertedItem) {
    $('.selectpicker').selectpicker();
  });

  $(".supply-name").on("click", function () {
    $(this).select();
  });
  $(".supply-lot-name").on("click", function () {
    $(this).select();
  });


  // Función para autocompletar matrícula del doctor
  jQuery(function() {
    var termTemplate = "<span class='ui-autocomplete-term'>%s</span>";

    return $('#prof_enrollment').autocomplete({
      source: $('#prof_enrollment').data('autocomplete-source'),
      minLength: 2,
      select:
      function (event, ui) {
        $("#professional_id").val(ui.item.id);
        $("#professional").val(ui.item.fullname);
        $('#patient_dni').focus();
      },
      response: function(event, ui) {
        if (!ui.content.length) {
            var noResult = { value:"",label:"No se encontró al doctor" };
            ui.content.push(noResult);
        }
      }
    })
  });

  // Función para autocompletar nombre y apellido del doctor
  jQuery(function() {
    var termTemplate = "<span class='ui-autocomplete-term'>%s</span>";

    return $('#professional').autocomplete({
      source: $('#professional').data('autocomplete-source'),
      minLength: 2,
      select:
      function (event, ui) {
        $("#professional_id").val(ui.item.id);
        $("#prof_enrollment").val(ui.item.enrollment);
        $('#patient_dni').focus();
      },
      response: function(event, ui) {
        if (!ui.content.length) {
            var noResult = { value:"",label:"No se encontró al doctor" };
            ui.content.push(noResult);
        }
      }
    })
  });

  // Función para autocompletar DNI del paciente
  jQuery(function() {
    var termTemplate = "<span class='ui-autocomplete-term'>%s</span>";

    return $('#patient_dni').autocomplete({
      source: $('#patient_dni').data('autocomplete-source'),
      minLength: 2,
      select:
      function (event, ui) {
        $("#patient_id").val(ui.item.id);
        $("#patient").val(ui.item.fullname);
        $('.supply-code').focus();
      }
    })
  });

  // Función para autocompletar Nombre de paciente
  jQuery(function() {
    var termTemplate = "<span class='ui-autocomplete-term'>%s</span>";

    return $('#patient').autocomplete({
      source: $('#patient').data('autocomplete-source'),
      minLength: 3,
      response: function (data) {
        if (data.length < 1) {
          $("#patient").tooltip({
            placement: 'bottom',trigger: 'manual', title: 'No se encontró el paciente'}).tooltip('show');
        }
      },
      select:
      function (event, ui) {
        $("#patient").tooltip('hide');
        $("#patient_id").val(ui.item.id);
        $("#patient_dni").val(ui.item.dni);
        $('.supply-code').focus();
      }
    })
  });

  // Ocultar tooltip
  $(document).on('focusout', '#patient', function() {
    $(this).tooltip('hide');
  });

  $.ui.autocomplete.prototype._renderItem = function (ul, item) {   
    if(item.length > 0 ){
      console.log("hay elementos");
    }     
    var t = String(item.value).replace(
            new RegExp(this.term, "gi"),
            "<strong>$&</strong>");
    return $("<li></li>")
      .data("item.autocomplete", item)
      .append("<div>" + t + "</div>")
      .appendTo(ul);
  };

  $(document).on("keyup change",".treat-durat", function() {
    var _this = $(this);
    jQuery(function() {
      var nested_form = _this.parents(".nested-fields");
      var request_quantity = nested_form.find(".request-quantity");
      var daily_dose = nested_form.find(".daily-dose");
      daily_dose.val(1);
      request_quantity.val( _this.val() * daily_dose.val());
    });
  });

  $(document).on("keyup change",".daily-dose", function() {
    var _this = $(this);
    jQuery(function() {
      var nested_form = _this.parents(".nested-fields");
      var request_quantity = nested_form.find(".request-quantity");
      var treat_durat = nested_form.find(".treat-durat");
      request_quantity.val( treat_durat.val() * _this.val());
    });
  });

  $(document).on("keyup change",".request-quantity", function() {
    var _this = $(this);
    jQuery(function() {
    });
  });
});