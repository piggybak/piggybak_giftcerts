$(function() {
	$('#giftcert_code').change(function() {
		piggybak_giftcerts.apply_giftcert();
	});
	$(piggybak.shipping_els).on('change', function() {
		if($('#giftcert_code').val() != '') {
			setTimeout(function() {
				piggybak_giftcerts.apply_giftcert();
			}, 500);
		}
	});
	$('#shipping select').on('change', function() {
		piggybak_giftcerts.apply_giftcert();
	});
	setTimeout(function() {
		if($('#giftcert_code').val() != '') {
			piggybak_giftcerts.apply_giftcert();
		}
	}, 500);
	$('#coupon_code').change(function() {
		setTimeout(function() {
			piggybak_giftcerts.apply_giftcert();
		}, 500);
	});
});

var piggybak_giftcerts = {
	apply_giftcert: function() {
		$('#giftcert_ajax').show();
		$('#giftcert input[type=hidden]').remove();
		$('#giftcert_response, #giftcert_application_row').hide();
		$('#giftcert_application_total').html('$0.00');
		if(!$('#payment').is(':visible')) {
			$('#piggybak_order_line_items_attributes_1_payment_attributes_number').val('');
			$('#payment').show();
		}
		var totalcost = piggybak.update_totals();
		$.ajax({
			url: giftcert_lookup,
			cached: false,
			data: {
				code: $('#giftcert_code').val(),
				totalcost: piggybak.update_totals()
			},
			dataType: "JSON",
			success: function(data) {
				if(data.valid_giftcert) {
					var el1 = $('<input>').attr('type', 'hidden').attr('name', 'piggybak_order[line_items_attributes][3][line_item_type]').val('giftcert_application');
					var el2 = $('<input>').attr('type', 'hidden').attr('name', 'piggybak_order[line_items_attributes][3][giftcert_application_attributes][code]').val($('#giftcert_code').val());
					$('#giftcert').append(el1);
					$('#giftcert').append(el2);
					$('#giftcert_response').html('Gift Certificate successfully applied to order.').show();
					$('#giftcert_application_total').html('-$' + (-1*parseFloat(data.amount)).toFixed(2));
					$('#giftcert_application_row').show();
					piggybak.update_totals();
					if($('#order_total').html() == '$0.00') {
						$('#piggybak_order_line_items_attributes_1_payment_attributes_number').val('giftcert');
						$('#payment').hide();
					}
				} else {
					if($('#giftcert_code').val() != '') {
						$('#giftcert_response').html(data.message).show();
					}
					piggybak.update_totals();
				}
				$('#giftcert_ajax').hide();
			},
			error: function() {
				$('#giftcert_ajax').hide();
			}
		});
	}	
};
