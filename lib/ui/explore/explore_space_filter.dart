enum ExploreFilter { allSpaces, nearby, topRated }

extension ExploreFilterLabel on ExploreFilter {
  String get label {
    switch (this) {
      case ExploreFilter.allSpaces:
        return 'All Spaces';
      case ExploreFilter.nearby:
        return 'Nearby';
      case ExploreFilter.topRated:
        return 'Top Rated';
    }
  }
}