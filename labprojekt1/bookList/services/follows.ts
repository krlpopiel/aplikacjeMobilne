import { supabase } from '@/utils/supabase'

export type UserFollow = {
    id: number;
    follower_id: string;
    following_id: string;
    created_at: string;
}

export const followUser = async (followerId: string, followingId: string) => {
    const { data, error } = await supabase
        .from('user_follows')
        .insert([{ follower_id: followerId, following_id: followingId }])
        .select()
        .single()

    if (error) throw error
    return data as UserFollow
}

export const unfollowUser = async (followerId: string, followingId: string) => {
    const { error } = await supabase
        .from('user_follows')
        .delete()
        .eq('follower_id', followerId)
        .eq('following_id', followingId)

    if (error) throw error
}

export const fetchFollowing = async (followerId: string) => {
    const { data, error } = await supabase
        .from('user_follows')
        .select('*')
        .eq('follower_id', followerId)

    if (error) throw error
    return data as UserFollow[]
}

export const isFollowing = async (followerId: string, followingId: string) => {
    const { data, error } = await supabase
        .from('user_follows')
        .select('id')
        .eq('follower_id', followerId)
        .eq('following_id', followingId)

    if (error) throw error
    return data.length > 0
}

export const fetchUserEmail = async (userId: string) => {
    const { data, error } = await supabase
        .from('user_profiles')
        .select('email')
        .eq('id', userId)
        .single()

    if (error) {
        return userId.substring(0, 8) + '...'
    }
    return data?.email || userId.substring(0, 8) + '...'
}
