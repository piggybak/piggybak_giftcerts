$(function() {
	$('#giftcert_code').change(function() {
		$(this).data('changed', true);
	});
	$('#shipping select').change(function() {
		piggybak_giftcerts.apply_giftcert(false);
		return false;		
	});
	$('#apply_giftcert').click(function() {
		piggybak_giftcerts.apply_giftcert(false);
		return false;		
	});
	$('#submit input').click(function() {
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
		$('#giftcert_response').hide();
		$.ajax({
			url: giftcert_lookup,
			cached: false,
			data: {
				code: $('#giftcert_code').val(),
				shipcost: $('#shipping_total').html().replace(/^\$/, '')
			},
			dataType: "JSON",
			success: function(data) {
				if(data.valid_giftcert) {
					var el1 = $('<input>').attr('type', 'hidden').attr('name', 'piggybak_order[line_items_attributes][2][line_item_type]').val('giftcert_application');
					var el2 = $('<input>').attr('type', 'hidden').attr('name', 'piggybak_order[line_items_attributes][2][giftcert_application_attributes][code]').val($('#giftcert_code').val());
					$('#giftcert').append(el1);
					$('#giftcert').append(el2);
					$('#giftcert_response').html('Coupon successfully applied to order.');
					$('#giftcert_application_total').html('-$' + (-1*parseFloat(data.amount)).toFixed(2));
					$('#giftcert_application_row').show();
					piggybak.update_totals();
				} else {
					$('#giftcert_response').html(data.message).show();
					$('#giftcert_application_total').html('$0.00');
					$('#giftcert_application_row').hide();
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
