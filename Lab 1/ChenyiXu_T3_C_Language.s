void recursiveSort(int arr[], int n, int i){
	
	//if index is less than equal to 1, return
	
	if(i <= n){
		return; 
	}
	

	int i = 1; 
	int j = i; 
	int value = arr[i]; 

	
	//while loop to sort the array
	//under the condition j >0 and arr[j] bigger than value
	
	while(j >= 0 && arr[j-1] > value){
		arr[j]=arr[j-1];
		j--; 
	}
	
	arr[j] = value; 

	recursiveSort(arr, n, i+1); //call the same function recursively 
}
