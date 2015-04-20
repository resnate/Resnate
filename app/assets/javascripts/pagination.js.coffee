jQuery ->
	$('#feedBox').on 'scroll', ->
		if $('.infinite-scrolling .pagination').length
    		@url = $('.infinite-scrolling .next').find('a').attr('href')
    		if @url && $('#feedBox').scrollTop() > $(document).height() - $('#feedBox').height() - 1000
    			$('.infinite-scrolling').remove()
    			$.get @url, (response) ->
    				$('#feedBox').append(response)
    			
    				