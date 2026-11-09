import type { ClubType, ShotType } from './types';
import { CLUB_LABELS, SHOT_LABELS } from './types';

export interface LoadingTip {
	text: string;
	category: 'general' | 'technique' | 'recording' | 'fun';
}

export const LOADING_TIPS: LoadingTip[] = [
	{ text: 'Film from the side so shoulder and hip rotation stay clear.', category: 'recording' },
	{ text: 'Ideal length is 5–8 seconds — enough for one full swing.', category: 'recording' },
	{ text: 'A solid tempo: three counts on the backswing, one on the downswing.', category: 'technique' },
	{ text: 'A quiet head leads to more consistent contact. Don’t lift too early.', category: 'technique' },
	{ text: 'A balanced finish on the lead foot signals clean weight transfer.', category: 'technique' },
	{ text: 'Clothes that contrast with the background help pose detection.', category: 'recording' },
	{ text: 'Pros average about 0.75 seconds on the backswing — no rush needed.', category: 'fun' },
	{ text: 'Five minutes of mirror practice before filming can improve posture.', category: 'technique' },
	{ text: 'Avoid backlight — keep the body brighter than the background.', category: 'recording' },
	{ text: 'Consistency beats distance. Repeat the same swing.', category: 'general' },
	{ text: 'The system maps 17 joint points to compute your swing metrics.', category: 'general' },
	{ text: 'Every swing is data. This analysis helps you iterate faster.', category: 'general' }
];

export function getPersonalizedTips(club: ClubType, shotType: ShotType): LoadingTip[] {
	const clubLabel = CLUB_LABELS[club] ?? club;
	const shotLabel = SHOT_LABELS[shotType] ?? shotType;

	const personalized: LoadingTip[] = [
		{
			text: `${shotLabel} · ${clubLabel} — analysis profile tuned for this pairing.`,
			category: 'general'
		}
	];

	if (shotType === 'putt') {
		personalized.push({
			text: 'Putt: keep the head steady and match the pendulum rhythm.',
			category: 'technique'
		});
	} else if (shotType === 'chip' || shotType === 'pitch') {
		personalized.push({
			text: 'Short game: minimal motion — control matters more than power.',
			category: 'technique'
		});
	} else if (club === 'driver') {
		personalized.push({
			text: 'Driver: wide turn plus smooth tempo builds distance without losing accuracy.',
			category: 'technique'
		});
	}

	return [...personalized, ...LOADING_TIPS];
}
