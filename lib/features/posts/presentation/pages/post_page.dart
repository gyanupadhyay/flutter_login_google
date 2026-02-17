import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter_login_google/core/constants/string_constants.dart';
import 'package:flutter_login_google/core/constants/ui_constants.dart';
import 'package:flutter_login_google/core/widgets/error_banner.dart';
import 'package:flutter_login_google/features/posts/domain/entities/post_entity.dart';
import 'package:flutter_login_google/features/posts/presentation/bloc/post_bloc.dart';
import 'package:flutter_login_google/features/posts/presentation/bloc/post_event.dart';
import 'package:flutter_login_google/features/posts/presentation/bloc/post_state.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key, this.onLogout, this.userName});

  final VoidCallback? onLogout;
  final String? userName;

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Fetch initial posts
    context.read<PostBloc>().add(const PostFetchRequested());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final bloc = context.read<PostBloc>();
    final state = bloc.state;
    if (state is! PostLoaded) {
      if (kDebugMode) {
        debugPrint('[PostPage] onScroll ignored: state=${state.runtimeType}');
      }
      return;
    }
    if (state is PostPaginating) {
      if (kDebugMode) {
        debugPrint('[PostPage] onScroll ignored: already paginating');
      }
      return;
    }
    if (!state.hasMore) {
      if (kDebugMode) {
        debugPrint('[PostPage] onScroll ignored: hasMore=false');
      }
      return;
    }

    final position = _scrollController.position;
    if (position.maxScrollExtent <= 0) {
      if (kDebugMode) {
        debugPrint(
          '[PostPage] onScroll ignored: not scrollable (max=${position.maxScrollExtent})',
        );
      }
      return;
    }

    final triggerAt =
        position.maxScrollExtent - AppSizes.scrollLoadMoreThreshold;
    if (kDebugMode) {
      debugPrint(
        '[PostPage] scroll px=${position.pixels.toStringAsFixed(1)} max=${position.maxScrollExtent.toStringAsFixed(1)} triggerAt=${triggerAt.toStringAsFixed(1)}',
      );
    }

    if (position.pixels >= triggerAt) {
      if (kDebugMode) {
        debugPrint(
          '[PostPage] dispatch PostLoadMoreRequested (page=${state.currentPage}, count=${state.posts.length})',
        );
      }
      bloc.add(const PostLoadMoreRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = (widget.userName?.trim().isNotEmpty ?? false)
        ? widget.userName!.trim()
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          displayName == null
              ? StringConstants.welcome
              : '${StringConstants.welcome}, $displayName',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (widget.onLogout != null)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: widget.onLogout,
            ),
        ],
      ),
      body: BlocBuilder<PostBloc, PostState>(
        builder: (context, state) {
          if (state is PostLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PostError) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.lg),
                  child: ErrorBanner(
                    message: state.message,
                    errorType: ErrorType.server,
                    canRetry: true,
                    onRetry: () {
                      context.read<PostBloc>().add(
                            const PostRefreshRequested(),
                          );
                    },
                    onDismiss: () {
                      context.read<PostBloc>().add(
                            const PostFetchRequested(),
                          );
                    },
                  ),
                ),
                Expanded(
                  child: Center(
                    child: TextButton.icon(
                      onPressed: () {
                        context.read<PostBloc>().add(
                              const PostRefreshRequested(),
                            );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ),
                ),
              ],
            );
          }

          if (state is PostLoaded) {
            final posts = state.posts;
            final isPaginating = state is PostPaginating;
            if (posts.isEmpty) {
              return const Center(child: Text('No posts available'));
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<PostBloc>().add(const PostRefreshRequested());
              },
              child: ListView.builder(
                controller: _scrollController,
                padding: AppInsets.screen,
                itemCount: posts.length + (isPaginating ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= posts.length) {
                    return const Padding(
                      padding: AppInsets.screen,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return _PostItem(post: posts[index]);
                },
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class _PostItem extends StatelessWidget {
  const _PostItem({required this.post});

  final PostEntity post;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Padding(
        padding: AppInsets.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: AppInsets.badge,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AppRadii.xs),
                  ),
                  child: Text(
                    'Post #${post.id}',
                    style: TextStyle(
                      fontSize: AppSizes.postBadgeText,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'User ${post.userId}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              post.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              post.body,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
