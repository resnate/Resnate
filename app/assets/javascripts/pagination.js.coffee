jQuery ->
	$('#feedBox').on 'scroll', ->
		if $('.pagination').length
    		@url = $('.next').find('a').attr('href')
    		if @url && $('#feedBox').scrollTop() > $(document).height() - $('#feedBox').height() - 1000
    			$('#infinite-scrolling').remove()
    			$.get @url, (response) ->
    				$('#feedBox').append(response)
    			
    				