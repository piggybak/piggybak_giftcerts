$(function() {
	$('#giftcert_code').change(function() {
		$(this).data('changed', true);
	});
	piggybak.shipping_els.live('change', function() {
		if($('#giftcert_code').val() != '') {
			setTimeout(function() {
				$('#giftcert_code').data('changed', true);
				piggybak_giftcerts.apply_giftcert(false);
			}, 500);
		}
	});
	$('#shipping select').live('change', function() {
		$('#giftcert_code').data('changed', true);
		piggybak_giftcerts.apply_giftcert(false);
	});
	$('#apply_giftcert').click(function() {
		piggybak_giftcerts.apply_giftcert(false);
		return false;		
	});
	$('#submit input').unbind('click').click(function(e) {
		piggybak_giftcerts.apply_giftcert(true);
		return false;
	});
	setTimeout(function() {
		if($('#giftcert_code').val() != '') {
			$('#giftcert_code').data('changed', true);
			piggybak_giftcerts.apply_giftcert(false);
		}
	}, 500);
});

var piggybak_giftcerts = {
	apply_giftcert: function(on_submit) {
		if(!$('#giftcert_code').data('changed')) {
			if(on_submit) {
				$('#new_piggybak_order').submit();
			}
			return;
		}
		$('#giftcert_code').data('changed', false);
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
					$('#giftcert_response').html('Coupon successfully applied to order.');
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
				if(on_submit) {
					$('#new_piggybak_order').submit();
				}
			},
			error: function() {
				//do nothing right now
			}
		});
	}	
};
