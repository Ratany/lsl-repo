

#include <lslstddef.h>


#define fUNDETERMINED              -1.0
#define fIsUndetermined(_f)        (fUNDETERMINED == _f)

#define fMetersPerSecond           3.0
#define fSecondsForMeters(d)       FMax((d), 0.03)

#define fRANGE(_f)                 (_f)
#define vMINRANGE(_f)              (<_f, _f, _f>)
#define fRandom(_fr)               (llFrand(fRANGE(_fr)) - llFrand(fRANGE(_fr)))
#define vRandomDistance(_fr, _fm)  (<fRandom(_fr), fRandom(_fr), fRandom(_fr)> + vMINRANGE(_fm))

#define fDistRange                 3.5
#define fMinDist                   0.5


default
{
	event touch_start(int t)
	{
		unless(llDetectedKey(0) == llGetOwner())
			{
				return;
			}

		vector here = llGetPos();
		list agents = llGetAgentList(AGENT_LIST_PARCEL, []);

#define iSTRIDE_agents     1
#define kAgentKey(x)       llList2Key(agents, x)
#define vAgentPos(x)       RemotePos(kAgentKey(x))
#define fAgentDistance(x)  llVecDist(here, vAgentPos(x))

		float distance = fUNDETERMINED;
		int goto;
		int agent = Len(agents);
		while(agent)
			{
				agent -= iSTRIDE_agents;

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
				vector offset = vRandomDistance(fDistRange, fMinDist);
				offset += PosOffset(here, vAgentPos(goto));
				llSetKeyframedMotion([offset,
						      fSecondsForMeters(distance)],
						     [KFM_DATA, KFM_TRANSLATION]);
			}

#undef AgentKey
#undef AgentPos
#undef AgentDistance

	}

	event state_entry()
	{
		SLPPF(LINK_THIS, [PRIM_PHYSICS_SHAPE_TYPE, PRIM_PHYSICS_SHAPE_CONVEX]);
	}
}
