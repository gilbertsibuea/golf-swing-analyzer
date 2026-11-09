import type { ClubType, ShotType, SwingAnalysis, SwingMetricsSummary } from './types';
import { CLUB_LABELS, SHOT_LABELS } from './types';

export type MetricKey = keyof SwingMetricsSummary;

export interface NextSwingAction {
	metric: MetricKey;
	label: string;
	score: number;
	priority: 'high' | 'medium';
	focus: string;
	drill: string;
}

export interface NextSwingPlan {
	actions: NextSwingAction[];
	club: string;
	shotType: string;
	clubLabel: string;
	shotLabel: string;
	analyzeUrl: string;
}

const METRIC_LABELS: Record<MetricKey, string> = {
	tempo: 'Tempo',
	posture: 'Posture',
	rotation: 'Rotation',
	balance: 'Balance',
	head_stability: 'Head stability'
};

const BASE_DRILLS: Record<MetricKey, { focus: string; drill: string }> = {
	tempo: {
		focus: 'Backswing : downswing ratio ≈ 3 : 1',
		drill: 'Count frames or rhythm: 3 counts up, 1 count down. Avoid rushing the top transition.'
	},
	posture: {
		focus: 'Spine angle retention from address → impact',
		drill: 'Keep spine angle (mid-hip to mid-shoulder) consistent. Avoid early extension or standing up before impact.'
	},
	rotation: {
		focus: 'X-factor: shoulder turn greater than hip turn',
		drill: 'Coil the shoulders back while limiting hip rotation. Aim for a 20–40° gap at the top of the swing.'
	},
	balance: {
		focus: 'Minimize lateral sway on the backswing',
		drill: 'Keep mid-hip stable relative to the trail ankle. Transfer weight without sliding toward the target.'
	},
	head_stability: {
		focus: 'Minimal head movement relative to shoulder width',
		drill: 'Measure stability from the nose/ear. Keep head movement under 15% of shoulder width from address to impact.'
	}
};

const SHOT_DRILL_OVERRIDES: Partial<
	Record<ShotType, Partial<Record<MetricKey, { focus?: string; drill?: string }>>>
> = {
	full_swing: {
		rotation: {
			focus: 'Max shoulder turn without sway',
			drill: 'Coil back until the trail shoulder nearly covers the target, keeping the hips quiet.'
		}
	},
	chip: {
		balance: {
			focus: 'Weight forward & firm wrists',
			drill: '70% weight on the lead foot. Short stroke like a putt with a slight wrist hinge.'
		},
		head_stability: {
			focus: 'Very quiet head — minimal motion',
			drill: 'Chip = control. Keep the head nearly still through the stroke.'
		}
	},
	pitch: {
		tempo: {
			focus: 'Accelerate through impact — don’t decelerate',
			drill: 'Short backswing, full follow-through. Feel the club fall into the ball.'
		}
	},
	putt: {
		head_stability: {
			focus: 'Head completely still through the stroke',
			drill: 'Listen for impact — don’t look. Hold head position until the putter passes the ball.'
		},
		balance: {
			focus: 'Lower body like a statue',
			drill: 'Only shoulders and arms move. Feet and hips stay still for the whole putt.'
		}
	}
};

const CLUB_DRILL_OVERRIDES: Partial<
	Record<ClubType, Partial<Record<MetricKey, { focus?: string; drill?: string }>>>
> = {
	driver: {
		rotation: {
			focus: 'Wide turn for max distance',
			drill: 'Long backswing with a full coil. A wider stance helps rotation without losing balance.'
		}
	},
	wedge: {
		balance: {
			focus: 'Minimal, controlled weight shift',
			drill: 'Wedge shot = precision. Soft weight transfer; avoid a lateral body slide.'
		}
	},
	putter: {
		tempo: {
			focus: 'Same pendulum motion every putt',
			drill: 'Match backswing and follow-through length — like a clock pendulum.'
		}
	}
};

function mergeDrill(
	metric: MetricKey,
	shotType: ShotType,
	club: ClubType
): { focus: string; drill: string } {
	const base = BASE_DRILLS[metric];
	const shot = SHOT_DRILL_OVERRIDES[shotType]?.[metric];
	const clubOverride = CLUB_DRILL_OVERRIDES[club]?.[metric];
	return {
		focus: clubOverride?.focus ?? shot?.focus ?? base.focus,
		drill: clubOverride?.drill ?? shot?.drill ?? base.drill
	};
}

export function getNextSwingPlan(report: SwingAnalysis): NextSwingPlan {
	const summary = report.metrics.summary;
	const shotType = report.shot_type as ShotType;
	const club = report.club as ClubType;

	const entries = (Object.entries(summary) as [MetricKey, number][]).sort((a, b) => a[1] - b[1]);

	const actions: NextSwingAction[] = entries.slice(0, 3).map(([metric, score], i) => {
		const { focus, drill } = mergeDrill(metric, shotType, club);
		return {
			metric,
			label: METRIC_LABELS[metric],
			score,
			priority: i === 0 || score < 65 ? 'high' : 'medium',
			focus,
			drill
		};
	});

	const params = new URLSearchParams({ club, shot_type: shotType });

	return {
		actions,
		club,
		shotType,
		clubLabel: CLUB_LABELS[club] ?? club,
		shotLabel: SHOT_LABELS[shotType] ?? shotType,
		analyzeUrl: `/analyze?${params.toString()}`
	};
}
