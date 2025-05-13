part of 'chatbloc_bloc.dart';

@immutable
abstract class ChatblocState {}

class ChatblocInitial extends ChatblocState {}

class ChatBlocLoadingState extends ChatblocState {}

class ChatBlocFailedState extends ChatblocState {}

class ChatBlocLoadedState extends ChatblocState {}
