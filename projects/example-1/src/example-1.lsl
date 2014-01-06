

#include <lslstddef.h>


#define fUNDETERMINED              -1.0

#define fIsUndetermined(_f)        (fUNDETERMINED == _f)

#define fMetersPerSecond           3.0
#define fSecondsForMeters(d)       FMax((d), 0.03)

#define fRandom                    (llFrand(3.5) - llFrand(2.5))
#define vRandomDistance            (<fRandom, fRandom, fRandom>)


default
{
	event touch_start(int t)
	{
		if(llDetectedKey(0) == llGetOwner())
			{
				vector here = llGetPos();

				list agents = llGetAgentList(AGENT_LIST_PARCEL, []);

#define kAgentKey(x)       llList2Key(agents, x)
#define vAgentPos(x)       RemotePos(kAgentKey(x))
#define fAgentDistance(x)  llVecDist(here, vAgentPos(x))

				float distance = fUNDETERMINED;
				int goto;
				int agent = Len(agents);
				while(agent)
					{
						--agent;

						float this_agent_distance = fAgentDistance(agent);
						if(distance < this_agent_distance)
							{
								distance = this_agent_distance;
								goto = agent;
							}
					}

				unless(fIsUndetermined(distance))
					{
						distance /= fMetersPerSecond;
						vector offset = vRandomDistance;
						offset += PosOffset(here, vAgentPos(goto));
						llSetKeyframedMotion([offset, fSecondsForMeters(distance)], [KFM_DATA, KFM_TRANSLATION]);
					}

#undef AgentKey
#undef AgentPos
#undef AgentDistance

			}
	}
}
