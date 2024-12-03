import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/random_user_list_res.dart';
import '../services/http_service.dart';
import '../views/itme_of_random_user.dart';

final randomUserListProvider = FutureProvider.family((ref,int currentPage) async{

  var response = await Network.GET(Network.API_RANDOM_USER_LIST, Network.paramsRandomUserList(currentPage));
  var randomUserListRes = Network.parseRandomUserList(response!);
  return randomUserListRes.results;

});

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  List<RandomUser> randomUserList = [];
  ScrollController scrollController = ScrollController();
  int currentPage = 1;

  @override
  void initState() {
    super.initState();
    ref.read(randomUserListProvider(currentPage));

    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent <= scrollController.offset) {
        ref.read(randomUserListProvider(currentPage));
      }
    });
  }


  @override
  Widget build(BuildContext context) {

    final userListAsync = ref.watch(randomUserListProvider(currentPage));

    return Scaffold(
        backgroundColor: const Color.fromRGBO(232, 232, 232, 1),
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text("Random User - Riverpod"),
        ),
        body: Stack(
          children: [

            userListAsync.when(
              data: (userList){
                randomUserList.addAll(userList);
                return ListView.builder(
                  controller: scrollController,
                  itemCount: userList.length,
                  itemBuilder: (ctx, index) {
                    return itemOfRandomUser(userList[index], index);
                  },
                );
              },
              error: (error,stackTrace) => Center(child: Text("Error $error"),),
              loading: () => Center(child: CircularProgressIndicator(),),

            ),

          ],
        ));
  }

}