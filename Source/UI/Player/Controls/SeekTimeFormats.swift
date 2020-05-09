
public enum TimeElapsedDisplayType: String {

    case formatted
    case seconds
    case percentage

    func toggle() -> TimeElapsedDisplayType {

        switch self {

        case .formatted:    return .seconds

        case .seconds:      return .percentage

        case .percentage:   return .formatted

        }
    }
}

public enum TimeRemainingDisplayType: String {

    case formatted
    case duration_formatted
    case duration_seconds
    case seconds
    case percentage

    func toggle() -> TimeRemainingDisplayType {

        switch self {

        case .formatted:    return .seconds

        case .seconds:      return .percentage

        case .percentage:   return .duration_formatted

        case .duration_formatted:     return .duration_seconds

        case .duration_seconds:     return .formatted

        }
    }
}
