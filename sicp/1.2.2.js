var coins_value = {1:1,2:5,3:10,4:25,5:50};


function count_change(amount){
	return cc(amount,coins_value.length)
}

function cc(amount, coins){
	if(amount === 0)
		return 1
	if((amount < 0) || (coins === 0))
		return 0
	return cc(amount, (coins - 1))  + cc( amount - first_denomination(coins), coins)
}



function first_denomination(coins){
	return coins_value[coins];
}

print(count_change(10))
