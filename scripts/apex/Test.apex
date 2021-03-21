System.debug('Hello World!');

public List<Integer> names() {
	return new List<Integer>{ 1, 2, 3, 4, 5, 6 };
}

List<Integer> listInt = new List<Integer>{ names() };

listInt.add(1);
listInt.add(23););
listInt.add(
for (Integer i : listInt) {
	System.debug('        ----> ' + i);
}
